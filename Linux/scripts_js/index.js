const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (query) => {
  return new Promise((resolve) => rl.question(query, resolve));
};

(async () => {
  try {
    const nome = await question("Qual é o seu nome? ");
    const idade = await question("Quantos anos você tem? ");
    const linguagem = await question("Qual linguagem de programação você está estudando? ");
    
    console.log(`Olá ${nome}, você tem ${idade} anos e já está aprendendo ${linguagem}!`);
  } catch (err) {
    console.error('Erro ao coletar dados:', err);
  } finally {
    rl.close();
  }
})();
