const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const app = express();

const lyrics = require("./apis/products/lyrics.js");

// set default views folder
app.set('views', __dirname + "/views");
app.engine('html', require('ejs').renderFile);
app.use(express.static('public'));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

// registra a sessão do usuário
app.use(session({
    secret: 'mysecret',
    saveUninitialized: false,
    resave: false
}));

const authRoutes = require('./apis/routes/auth.js');

app.get('/', (req, res) => {
    res.redirect('/api/auth');
});

// * Auth pages * //
app.use("/api/auth", authRoutes);

// * Products pages * //
app.get("/addLyrics", lyrics.renderAddLyrics);
app.get("/getLyrics", lyrics.renderGetLyrics);

app.post("/addLyrics", lyrics.addLyrics);
app.get("/listLyrics", lyrics.getLyrics);



const PORT = process.env.PORT || 3000;

app.listen(PORT, function() {
    console.log(`App listening on port ${PORT}`);
})