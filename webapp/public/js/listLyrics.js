window.addEventListener("load", function() {

    // função para carregar produtos
    getLyrics();
})

function getLyrics() {
    console.log("*** Getting Lyrics ***");

    $.get("/listLyrics", function(res) {
        
        if (!res.error) {

            if (res.msg === "sem letras até o momento") {
                return;
            }

            let letras = res.letras;

            // adiciona letras na tabela
            for (let i = 0; i < letras.length; i++) {
                let newRow = $("<tr>");
                let cols = "";
                let desc = letras[i].letra;
                let preco = letras[i].autor;
                let owner = letras[i].addr;

                cols += `<td> ${desc} </td>`;
                cols += `<td> ${preco} </td>`;
                cols += `<td> ${owner} </td>`;

                
                newRow.append(cols);
                $("#lyrics-table").append(newRow);
            }
            
        } else {
            alert("Erro ao resgatar produtos do servidor. Por favor, tente novamente mais tarde. " + res.msg);
        }

    })
}