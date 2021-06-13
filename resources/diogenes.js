function replace(element, from, to) {
    if (element.childNodes.length) {
        element.childNodes.forEach(child => replace(child, from, to));
    } else {
        const cont = element.textContent;
        if (cont) element.textContent = cont.replace(from, to);
    }
};

// go sex, yeah yeah, go sex, yeah

replace(document.body, new RegExp("shit", "g"), "brown stuff");
replace(document.body, new RegExp("penis", "mans worm"), "mans worm");
replace(document.body, new RegExp("pussy", "kitty"), "cat");
replace(document.body, new RegExp("fuck", "love"), "love");
replace(document.body, new RegExp("penis", "mans worm"), "mans worm");
replace(document.body, new RegExp("jared", "best guy ever"), "best guy ever");
