## Git LFS

- O Git não é a porra de um storage asset,mas um versionador de código, simplesmente. Asset não é código(textura, imagem, som, e os escambau), ai como faz a gambiarra pra os assets(.wav, .blend, .qualqueroutracaralha) grandes do game? NÂO COMMITA NORMAL, PORQUE DA MERDA DO TIPO REPO GIGANTESCO EM TAMANHO DENTRO DA PASTA .GIT.Plus github mais de 100MB num arquivo é R.I.P total. Ai a gambi chama git LFS, que é um plugin pensado no pobre coitado que precisa versionar esses assets.

### 💡 Conceito Principal

(42 only => troca a imagem por ponteiro de txt e quada o real em um servidor, se tu não manja de ponteiro volta no common core libft e estuda)

- Ele baixa só o que vc precisa quando vc quer usar, vulgo faz checkout em alguma coisa.Pra isso ele usa de hooks de commit pra separar codigo+ponteiros de arquivos grandes, os quais deixa em um cache local e quando vc envia o commit pro remoto ele envia esse cache pra o armazenamento remoto do lfs vinculado ao repo. (atenção gafanhoto que a quantidade de  armazenamento lfs difere do armazenamento de codigo nos provedores). Ai quando alguém faz o checkout ele verifica se tem no cache local (`.git/lfs/objects/`) ou pega do armazenamento remoto.


### 📝 Detalhes

Arquivo gitattributes: a sintaxe básica é

```
*.png filter=lfs diff=lfs merge=lfs -text
```

Cada parte tem um significado:

- `filter=lfs` — intercepta o arquivo na hora do stage e substitui pelo ponteiro
- `diff=lfs` — diz pro Git não tentar fazer diff de texto nesse arquivo
- `merge=lfs` — diz pro Git não tentar fazer merge automático de texto

#### O problema do CRLF (line ending)

Sistemas operacionais discordam sobre como representar "fim de linha" em arquivos de texto:

- **Linux/Mac** usam `LF` — Line Feed, o caractere `\n`
- **Windows** usa `CRLF` — Carriage Return + Line Feed, os caracteres `\r\n`

Isso existe desde os tempos de teletipos e é uma das heranças mais irritantes da computação. O Git, por padrão, tenta ser "gentil" e faz conversões automáticas dependendo do sistema operacional do usuário — converte pra CRLF quando alguém no Windows faz checkout, e converte de volta pra LF quando faz commit.

O problema é que essa gentileza **cria diffs fantasmas**. Imagine:

1. Você no Linux abre `PlayerController.gd`, não muda nada, salva
2. Sua colega no Windows abre o mesmo arquivo, não muda nada, salva
3. O Git vê o arquivo como "modificado" porque os line endings mudaram

O `git diff` vai mostrar que **cada linha do arquivo** foi alterada — não por mudança de conteúdo, mas por mudança de `\n` pra `\r\n`. Commits com centenas de linhas "alteradas" que na prática não mudaram nada. Histórico poluído, code reviews impossíveis.

-  O que `text eol=lf` no .gitattributes faz

```gitattributes
*.gd text eol=lf
```

Isso diz duas coisas ao Git:

**`text`** — trata esse arquivo como texto, não como binário. O Git pode fazer diff, merge e conversão nele.

**`eol=lf`** — independente do sistema operacional de quem está editando, esse arquivo **sempre** vai ser armazenado no repositório com `LF`, e sempre vai ser entregue no checkout com `LF`. O Git para de tentar ser gentil.

Isso significa que se alguém no Windows editar um `.gd` e o editor salvar com CRLF(detalhe, só mudar a config no editor de código pra salvar com LF PLEASE, tu ta codando sozinho jovem?!) , na hora do `git add` o Git converte de volta pra LF antes de guardar. O repositório fica consistente independente de quem commita de onde.

#### [[GODOT]]

 - salva `.tscn` e `.tres` como texto - ou seja, git NORMAL rastreia esses arquivos
 
Godot foi projetado com controle de versão em mente de uma forma que Unreal não foi. Algumas decisões de design que tornam a vida muito mais fácil:

**Formato de cena em texto.** Os arquivos `.tscn` (cenas) e `.tres` (recursos) são salvos como texto por padrão. Isso significa que dois designers trabalhando em cenas diferentes raramente vão colidir, e quando colidirem, o Git consegue mostrar o diff de forma legível.

**Sem arquivos de projeto binários grandes.** O `project.godot` é texto puro. Não tem equivalente ao `.uproject` + pasta `Saved` do Unreal que gera gigabytes de cache.

**Importação gerenciada.** O Godot gera arquivos `.import` para cada asset. Esses arquivos são metadados de texto que descrevem como o asset foi importado. A convenção da comunidade é **não commitar a pasta `.godot/`** (que contém os dados de importação compilados) e **commitar os `.import`** — eles são pequenos e permitem que qualquer pessoa que clone reimporte automaticamente.

### 💻 Exemplos

#### O que acontece se você esquecer de configurar antes de commitar

Esse é o erro mais comum e mais doloroso. Se você commitar um arquivo grande **antes** de configurar o LFS para aquela extensão, o arquivo vai pro Git normal. O LFS não retroage automaticamente. Corrigir isso depois exige reescrever o histórico com `git lfs migrate`, o que é trabalhoso e cria problemas pra quem já clonou o repo. (A todos lendo isso a não ser eu, se eu pedi pra vc ler isso, só segue A PORRA DO PASSO A PASSO que eu passei em algum lugar antes disso)

### 🔗 Relacionado

### 📚 Fonte
- https://www.atlassian.com/br/git/tutorials/git-lfs
- https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-git-lfs-objects-in-archives-of-your-repository
- https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage#pointer-file-format