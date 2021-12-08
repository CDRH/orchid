window.addEventListener("load", () => {
    const buttons = document.querySelectorAll("a[role='button']");
    buttons.forEach((element) => {
        element.addEventListener("keyup", (event) => {
            if (event.keyCode === 32) {
                event.preventDefault();
                element.click();
            }
        }) 
    });
 });
