function replace(element, from, to) {
    if (element.childNodes.length) {
        element.childNodes.forEach(child => replace(child, from, to));
    } else {
        const cont = element.textContent;
        if (cont) element.textContent = cont.replace(from, to);
    }
};

replace(document.body, new RegExp("shit", "swear"), "brown stuff");
