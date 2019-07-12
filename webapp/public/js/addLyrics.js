window.addEventListener("load", function() {

    
    // restaga formulário de produtos
    let form = document.getElementById("addLyrics");

    // adiciona uma função para
    // fazer o login quando o 
    // formulário for submetido
    form.addEventListener('submit', addProduct);
})

function addProduct() {

    // previne a página de ser recarregada
    event.preventDefault();

    $('#load').attr('disabled', 'disabled');

    // resgata os dados do formulário
    let letra = $("#letra").val();
    let autor = $("#autor").val();

    // envia a requisição para o servidor
    $.post("/addLyrics", {letra: letra, autor: autor}, function(res) {
        
        console.log(res);
        // verifica resposta do servidor
        if (!res.error) {
            // limpa dados do formulário
            $("#letra").val("");
            $("#autor").val("");
            
            // remove atributo disabled do botao
            $('#load').attr('disabled', false);

            alert("A letra foi cadastrada com sucesso");
        } else {
            alert("Erro: " + res.msg);
        }

    });
    
}