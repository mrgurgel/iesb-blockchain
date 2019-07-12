pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract MyContract {

    // evento para notificar o cliente que a conta foi atualizada
    event userRegisted(address _addr, string newEmail);
    // evento para notificar o cliente que o produto foi registrado
    event lyricRegistered(uint id);


    // estrutura para manter dados do usuário
    struct User {
        string email;
    }

    // estrutura para registar o estagio de um produto
    struct Stage {
        uint id;
        uint[] products;
        string desc;
        address owner;
    }

    // estrutura para manter dados do produto
    struct Lyric {
        uint id;
        string desc;
        string author;
        address owner;
    }

    // estrutura para manter dados de um histórico
    struct History {
        uint productId;
        string[] stageDesc;
        string[] dates;
        address productOwner;
    }

    // mapeia um id a uma letra
    mapping (uint => Lyric) lyrics;
    uint[] public lyricsIds;




    // mapeia endereço do usuário a sua estrutura
    mapping (address => User) users;

    // state variables
    uint256 private lastId = 0;


    // função para cadastrar conta do usuário
    function setUser(address _addr, string memory _email) public {
        User storage user = users[_addr];
        user.email = _email;

        // notifica o cliente através do evento
        emit userRegisted(_addr, "Conta registrada!");
    }

    // função para resgatar dados do usuário
    function getUser(address _addr) public view returns(string memory) {
        User memory user = users[_addr];
        return (user.email);
    }

    // função para cadastrar um produto
    function addLyric(string memory _lyric, string memory _author) public {
        require(bytes(_lyric).length >= 1, "Letra invalida");
        require(bytes(_author).length >= 1, "autor invalido");

        lyrics[lastId] = Lyric(lastId, _lyric, _author, msg.sender);
        lyricsIds.push(lastId);
        lastId++;
        emit lyricRegistered(lastId);
    }

    // função para resgatar info de um produto
    function lyricInfo(uint _id) public view
        returns(
            uint,
            string memory,
            address,
            string memory
        ) {
            require(_id <= lastId, "Product does not exist");

            Lyric memory lyric = lyrics[_id];

            return (
                lyric.id,
                lyric.desc,
                lyrics[_id].owner,
                lyric.author
            );
    }

    // função que retorna todos os produtos de um usuário
    function getLyrics() public view returns(uint[] memory, string[] memory, address[] memory, string   [] memory) {

        uint[] memory ids = lyricsIds;

        uint[] memory idsLyrics = new uint[](ids.length);
        string[] memory names = new string[](ids.length);
        address[] memory owners = new address[](ids.length);
        string[] memory authors = new string[](ids.length);

        for (uint i = 0; i < ids.length; i++) {
            (idsLyrics[i], names[i], owners[i], authors[i]) = lyricInfo(i);
        }

        return (idsLyrics, names, owners, authors);
    }


}