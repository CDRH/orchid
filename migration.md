# Migration

## 1.1.1 to 1.2.0

This major version introduces multiple language support.

__config/public.yml__

This bump adds the ability to control the following settings, but they are optional.  Default behavior is English language only.

```
# defaults to "en" (english) if no default language set
# language_default: en
# defaults to "en" if nothing passed in, pipe delineated values
# languages: en|es
```

__config/locales/en.yml__

Copy orchid's `config/locales/en.yml` file into the same location in your app.
