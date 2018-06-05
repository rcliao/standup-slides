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
    updateBackgroundImage();
}

function updateBackgroundImage() {
    let randomBackgroundUrl = '';

    const backgroundImages = [
        'imgs/bridge_raining.gif',
        'imgs/castle.gif',
        'imgs/dawn.gif',
        'imgs/et.gif',
        'imgs/falls.gif',
        'imgs/nature.gif',
        'imgs/northlights.gif',
        'imgs/pixelphony_2.gif',
        'imgs/watchdogs.gif'
    ];

    randomBackgroundUrl = backgroundImages[Math.floor(Math.random() * backgroundImages.length)];

    document.querySelector('.reveal')
        .setAttribute('style', `background-image: url(${randomBackgroundUrl})`);
}
