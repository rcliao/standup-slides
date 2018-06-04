import * as SimpleMDE from 'simplemde';

let editor = null;

export function render (onChangeCallback) {
    const editorDOM = document.querySelector('#note_editor');
    const debounceOnChange = debounce(() => {
        onChangeCallback(editor.value());
    }, 1000);
    if (editorDOM) {
        editor = new SimpleMDE({ element: editorDOM });
        editor.codemirror.on('change', debounceOnChange);
    } else {
        console.log('Editor DOM is not found. Cannot add editor widget');
    }
}
export function cleanup () {
    if (editor) {
        editor.toTextArea();
        editor = null;
    }
}

function debounce (func, wait, immediate) {
    let timeout;
    return function() {
        const context = this, args = arguments;
        const later = function() {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        const callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
}
