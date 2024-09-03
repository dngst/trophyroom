document.body.addEventListener('htmx:afterSwap', function(event) {
    if (event.detail.xhr.status === 200) {
        const albums = JSON.parse(event.detail.xhr.response);
        const container = event.detail.target;

        container.innerHTML = ''; 
        albums.forEach(album => {
            const img = document.createElement('img');
            img.src = album.image;
            img.alt = `${album.album} by ${album.artist}`;
            container.appendChild(img);
        });
    } else {
        console.error('Error loading album covers');
    }
});

