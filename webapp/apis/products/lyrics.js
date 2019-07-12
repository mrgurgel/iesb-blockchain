const path = require('path');
const Web3 = require("web3");

const product_abi = require(path.resolve("../dapp/build/contracts/MyContract.json"));
const httpEndpoint = 'http://localhost:8540';

let contractAddress = require('../../utils/parityRequests').contractAddress;

const OPTIONS = {
    defaultBlock: "latest",
    transactionConfirmationBlocks: 1,
    transactionBlockTimeout: 5
};

let web3 = new Web3(httpEndpoint, null, OPTIONS);

let MyContract = new web3.eth.Contract(product_abi.abi, contractAddress);

module.exports = {
    renderAddLyrics: function(req, res) {

        // verifica se usuario esta logado
        if (!req.session.username) {
            res.redirect('/api/auth');
            res.end();
        } else {
            res.render('letras.html');
        }
    },
    renderGetProducts: function(req, res) {
        // verifica se usuario esta logado
        if (!req.session.username) {
            res.redirect('/api/auth');
            res.end();
        } else {
            res.render('listaletras.html');
        }
    },
    renderEditProduct: function(req, res) {
        // verifica se usuario esta logado
        if (!req.session.username) {
            res.redirect('/api/auth');
            res.end();
        } else {
            res.render('editProduct.html');
        }
    },
    getLyrics: async function(req, res) {
        console.log(contractAddress)
        let userAddr = req.session.address;
        console.log("*** Getting lyrics from block chain ***", userAddr);

        await MyContract.methods.getLyrics()
            .call({ from: userAddr, gas: 3000000 })
            .then(function (lyric) {

                console.log("prod", lyric);
                if (lyric === null) {
                    return res.send({ error: false, msg: "no products yet"});
                }

                let letras = [];
                for (i = 0; i < lyric['0'].length; i++) {
                    letras.push({ 'id': +lyric['0'][i], 'letra': lyric['1'][i], 'addr': lyric['2'][i], 'autor': lyric['3'][i] });
                }

                console.log("lyrics", letras);

                res.send({ error: false, msg: "letras resgatados com sucesso", letras: letras});
                return true;
            })
            .catch(error => {
                console.log("*** productsApi -> getLyrics ***error:", error);
                res.send({ error: true, msg: error});
            })
        
    },
    addLyrics: async function(req, res) {

        if (!req.session.username) {
            res.redirect('/');
            res.end();
        } else {
            console.log("*** LyricsAPI -> AddLyric, acionando a block chain ***");
            console.log(req.body);

            let letra = req.body.letra;
            let autor   = req.body.autor;
            let userAddr = req.session.address;
            let pass     = req.session.password;

            try {
                let accountUnlocked = await web3.eth.personal.unlockAccount(userAddr, pass, null)
                if (accountUnlocked) {

                    await MyContract.methods.addLyric(letra, autor)
                        .send({ from: userAddr, gas: 3000000 })
                        .then(function(result) {
                            console.log(result);
                            return res.send({ 'error': false, 'msg': 'Letra cadastradada com sucesso.'});
                        })
                        .catch(function(err) {
                            console.log(err);
                            return res.send({ 'error': true, 'msg': 'Erro ao comunicar com o contrato.'});
                        })
                } 
            } catch (err) {
                return res.send({ 'error': true, 'msg': 'Erro ao adicionar letra: ' + err});
            }
        }
    },
    updateProduct: async (req, res) => {
        
        if (!req.session.username) {
            res.redirect('/');
            res.end();
        } else {
        
            let productId = req.body.productId;
            let newDesc   = req.body.newDesc;
            let newPrice  = req.body.newPrice;
            let userAddr  = req.session.address;
            let pass      = req.session.password;

            console.log("apis -> products -> updateProduct: ", userAddr, productId, newDesc, newPrice);

            try {
                let accountUnlocked = await web3.eth.personal.unlockAccount(userAddr, pass, null)
                console.log("Account unlocked?", accountUnlocked);
                if (accountUnlocked) {

                    await MyContract.methods.updateProduct(productId, newDesc, newPrice)
                        .send({ from: userAddr, gas: 3000000 })
                        .then(receipt => {
                            console.log(receipt);
                            return res.send({ 'error': false, 'msg': 'Produto atualizado com sucesso.'}); 
                        })
                        .catch((err) => {
                            console.log(err);
                            return res.json({ 'error': true, msg: "erro ao se comunar com o contrato"});
                        })
                }
            } catch (error) {
                return res.send({ 'error': true, 'msg': 'Erro ao desbloquear sua conta. Por favor, tente novamente mais tarde.'});
            }
        }
    }
}