pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract MyContract {

    // evento para notificar o cliente que a conta foi atualizada
    event userRegisted(address _addr, string newEmail);
    // evento para notificar o cliente que o produto foi registrado
    event lyricRegistered(uint id);
    // evento para notificar o cliente de que a Etapa foi registrada
    event StageRegistered(uint[]);
    // evento para notificar o cliente de que um histórico foi registrado
    event historyRegistered(string _msg);
    // evento para notificar o cliente de que um produto foi atualizado
    event productUpdated(uint _productId, string _msg);

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

    // mapeia um id a uma etapa
    mapping(uint => Stage) stages;
    uint[] public stagesIds;

    mapping (uint => History) histories;
    uint[] public historiesIds;
    uint[] public productsInHistory;

    // mapeia endereço do usuário a sua estrutura
    mapping (address => User) users;

    // state variables
    uint256 private lastId = 0;
    uint256 private stagesId = 0;
    uint256 private historyId = 0;

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

    function isProductInHistory(uint _id) public view returns (bool) {
        for (uint i = 0; i < productsInHistory.length; i++) {
            if (productsInHistory[i] == _id)
                return true;
        }
        return false;
    }

    // função para adicionar o histórico de um produto
    function addNewHistory(uint _productId, string[] memory _stageDesc, string[] memory _dates) public {
        require(_productId >= 0, "invalid productId");

        if (!isProductInHistory(_productId)) {
            histories[historyId] = History(_productId, _stageDesc, _dates, msg.sender);
            historiesIds.push(historyId);
            productsInHistory.push(_productId);
            historyId++;
            emit historyRegistered("History saved!");
        } else {
            bool added = addToHistory(_productId, _stageDesc, _dates);
            if (added) {
                emit historyRegistered("History saved!");
            }
        }
    }

    function addToHistory(uint _productId, string[] memory _stageDesc, string[] memory _dates) public returns (bool) {
        uint size = historiesIds.length;
        for (uint i = 0; i < size; i++) {
            if (histories[i].productId == _productId) {
                History storage his = histories[i];
                his.stageDesc.push(_stageDesc[0]);
                his.dates.push(_dates[0]);
                return true;
            }
        }
        return false;
    }

    function HistoryInfo(uint _id) public view returns (uint, string[] memory, string[] memory, address) {
        require(_id <= historyId, "History does not exist");

        History memory his = histories[_id];
        return (
            his.productId,
            his.stageDesc,
            his.dates,
            his.productOwner
        );
    }

    function getHistories() public view returns (string[] memory, string[][] memory, string[][] memory, address[] memory) {
        uint[] memory ids = historiesIds;

        uint[] memory prodsIds = new uint[](ids.length);
        string[] memory productsNames = new string[](ids.length);
        string[][] memory stageDesc = new string[][](ids.length);
        string[][] memory dates = new string[][](ids.length);
        address[] memory addrs = new address[](ids.length);

        for (uint i = 0; i < ids.length; i++) {
            (prodsIds[i], stageDesc[i], dates[i], addrs[i]) = HistoryInfo(i);
            (, productsNames[i], ,) = lyricInfo(prodsIds[i]);
        }

        return (productsNames, stageDesc, dates, addrs);
    }

    // função para adicionar produtos à um estágio
    function addToStage(uint[] memory _productsIds, string memory _stageDesc) public {
        require(bytes(_stageDesc).length >= 1, "Name invalid");
        require(_productsIds.length > 0, "Price must be higher than zero");

        stages[stagesId] = Stage(stagesId, _productsIds, _stageDesc, msg.sender);
        stagesIds.push(stagesId);
        stagesId++;

        emit StageRegistered(_productsIds);
    }

    // função para resgatar info de um estágio
    function stageInfo(uint _id) public view returns (uint, uint[] memory, string memory, address) {
        require(_id <= stagesId, "Product stage does not exist");

        Stage memory stage = stages[_id];
        return (stage.id, stage.products, stage.desc, stage.owner);
    }

    // função que retorna todos os produtos de um usuário
    function getStages() public view returns (uint[] memory, uint[][] memory, string[] memory, address[] memory) {

        uint[] memory ids = stagesIds;
        uint[] memory idsStages = new uint[](ids.length);
        uint[][] memory prods = new uint[][](ids.length);
        string[] memory prods_desc = new string[](ids.length);
        address[] memory owners = new address[](ids.length);

        for(uint i = 0; i < ids.length; i++) {
            (idsStages[i], prods[i], prods_desc[i], owners[i]) = stageInfo(i);
        }

        return (ids, prods, prods_desc, owners);
    }

}