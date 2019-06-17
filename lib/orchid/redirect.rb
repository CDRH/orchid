# Written with heavy influence from Rack::Rewrite,
# because its YAML loading seems broken at present
# from work done on Journals of Lewis and Clark rails app
# https://github.com/CDRH/lewisandclark/pull/101

# Matching YAML file format for Rack::Rewrite with feature subset
    # Method may only be "rewrite" or "r30[1,2,3,7,8]" syntax
# URL rewrites and redirects with regexes work, but no procs or sending files

# Additions
# - May specify to drop the query string with options['drop_qs']
# - Rewrites are checked again before returned to prevent multiple redirects

require 'yaml'

module Orchid
  class Redirect

    # Variables
    @@redirects = nil
    @@uri_prefix = nil

    private

    def initialize(app)
      @app = app
      # Save redirects as class variable to only load once at server start
      if @@redirects.nil?
        redirect_files = APP_OPTS["redirect_files"]
        @@redirects = compile_redirects(redirect_files)
      end
    end

    protected

    def _call(env)
      # Determine if URI prefix upon receiving first request
      if @@uri_prefix.nil?
        request = Rack::Request.new(env)

        if request.path_info != request.path
          # Remove last occurrence of path_info
          # so removing / from /prefix/ is /prefix
          @@uri_prefix = request.path.sub(/(.*)(#{request.path_info})(.*)/, '\1\3')
          puts "Orchid::Redirect - URI prefix set to '#{@@uri_prefix}'"
        else
          @@uri_prefix = ''
        end
      end

      response = !@@redirects.nil? ? route_request(env) : nil

      if !response.nil?
        response
      else
        @app.call(env)
      end
    end

    def compile_redirects(paths)
      # if no paths specified, then do not assign redirects
      if paths
        redirects = []
        paths.each { |path| redirects += load_yaml(File.join(Rails.root, path)) }
        redirects
      end
    end

    def compute_to(from, request, path_qs, to)
      # Prepend URI prefix if present
      to = @@uri_prefix + to if !@@uri_prefix.blank?

      if from.is_a?(Regexp) && (from.match(request.path_info) || from.match(path_qs))
        matched_path = from.match(request.path_info) \
          ? from.match(request.path_info) \
          : from.match(path_qs)

        computed_to = to.dup
        computed_to.gsub!("$&", matched_path.to_s)
        (matched_path.size - 1).downto(1) do |num|
          computed_to.gsub!("$#{num}", matched_path[num].to_s)
        end

        computed_to
      else
        to
      end
    end

    def load_yaml(path)
      YAML.load_file(path)
    rescue => e
      puts "Orchid::Redirect - Unable to open #{path}:\n  #{e}"
      exit 1
    end

    def match_options_not?(from_not, request, path_qs)
      !!(from_not.is_a?(Regexp) \
      && (request.path_info.match(from_not) || path_qs.match(from_not)) \
      || (request.path_info == from_not || path_qs == from_not))
    end

    def route_request(env)
      request = Rack::Request.new(env)
      path_qs = request.path_info || ''
      qs = request.query_string || ''
      if not qs.empty?
        path_qs += '?'+ qs
      end

      @@redirects.each do |redirect|
        options = !redirect['options'].nil? \
            ? redirect['options'] \
            : {}

        next if options['host'] && !request.host.match(options['host'])
        next if options['method'] && !env['REQUEST_METHOD'].match(options['method'])
        next if options['scheme'] && !request.scheme.match(options['scheme'])

        from = redirect['from']
        to = redirect['to']
        from_not = options['not'] || ''

        if rule_matches?(from, request, path_qs, from_not)
          # Response variables
          body = []
          headers = {}

          # Redirect variables
          method = redirect['method']
          to = compute_to(redirect['from'], request, path_qs, to)
          to_qs = (!qs.empty? && !options['drop_qs']) \
              ? (to + '?' + qs) \
              : to

          if to == request.path
            puts "Orchid::Redirect - Skipping rule that redirects to self in infinte loop"
            puts "  Request Path: #{request.path}"
            puts "  Rule From: #{from}"
            puts "  Rule To: #{redirect['to']}"
            puts "    Evals: #{to}"
            next
          end

          if method =~ /r30[12378]/
            status = method[1..-1]

            headers['Location'] = to_qs
            headers['Content-Type'] = Rack::Mime.mime_type(File.extname(to), fallback='text/html')

            body.push %Q{Redirecting to <a href="#{to_qs}">#{to_qs}</a>}

            puts "Orchid::Redirect - Redirecting #{path_qs} to #{to_qs}"

            return [status, headers, body]
          elsif method == "rewrite"
            env['REQUEST_URI'] = to_qs
            if q_index = to_qs.index('?')
                env['PATH_INFO'] = to_qs[0..q_index-1]
                env['QUERY_STRING'] = (!options['drop_qs']) \
                    ? to_qs[q_index+1..-1] \
                    : ''
            else
                env['PATH_INFO'] = to_qs
                env['QUERY_STRING'] = ''
            end

            puts "Orchid::Redirect - Rewriting #{path_qs} to #{to_qs}"

            # Recheck rules after rewrite
            return route_request(env)
          end
        end
      end

      nil
    end # /route_request

    def rule_matches?(from, request, path_qs, from_not)
      !!(from.is_a?(Regexp) \
      &&  ((request.path_info.match(from) || path_qs.match(from)) \
          && !match_options_not?(from_not, request, path_qs) \
      ) \
      || ((request.path_info == from || path_qs == from) \
          && !match_options_not?(from_not, request, path_qs) \
      ))
    end

    public

    def call(env)
      dup._call(env)  # Thread-safety for instance vars
    end

  end
end
