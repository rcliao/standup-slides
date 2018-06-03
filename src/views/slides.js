export function render () {
    window.Reveal.initialize({
        margin: 0.1,
        minScale: 0.7,
        maxScale: 1.5,
        embedded: true,
        dependencies: [
            { src: 'https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0/plugin/markdown/marked.js' },
            { src: 'https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0/plugin/markdown/markdown.js' }
        ]
    });
}

