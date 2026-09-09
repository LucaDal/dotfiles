# Configurazione Neovim

Il leader è **Spazio**. Indentazione generale a 4 spazi; Dart a 2 spazi,
anche durante la scrittura, coerentemente con il formatter ufficiale.

## Finestre e pannelli tmux

In modalità normale, `Ctrl+freccia` ridimensiona la finestra Neovim e
`Ctrl+g`, poi una freccia semplice, la sposta con WinShift. Rilascia Ctrl
prima di premere la freccia. Il focus segue la finestra;
il buffer e le opzioni della finestra vengono conservati. Nei layout misti,
WinShift può riorganizzare righe e colonne.

Se non esiste una finestra Neovim nella direzione scelta, lo spostamento passa
al pannello tmux che contiene l'intero editor. Fuori da Neovim, gli stessi
tasti ridimensionano o scambiano i pannelli tmux. Al bordo esterno lo scambio
non fa nulla. `Ctrl+h/j/k/l` continua a cambiare focus con tmux-navigator.

In tmux, `Ctrl+s`, poi `"` divide sopra/sotto; `Ctrl+s`, poi `%` divide
sinistra/destra. Sono disponibili anche `Ctrl+s -` e `Ctrl+s |`.

Lo spostamento non richiede configurazioni specifiche del terminale. In tmux,
`Escape` o un secondo `Ctrl+g` annulla la sequenza. Ricarica tmux e riavvia
Neovim dopo le modifiche ai mapping.

## Scrittura e completamento

Blink mostra suggerimenti da LSP, percorsi e snippet. La documentazione è spenta
di default: in modalità normale, `K` richiede la documentazione LSP del simbolo
sotto il cursore. Per leggere invece la documentazione di una voce del menu,
selezionala con Ctrl+n/Ctrl+p e premi Ctrl+Spazio. Una volta aperta, segue la
selezione; Ctrl+Spazio la nasconde nuovamente.
Il testo tenue sulla riga anticipa il suggerimento selezionato.
Il suggerimento viene inserito quando lo confermi con Tab.

Dopo modifiche alle scorciatoie di Blink, riavvia Neovim: ricaricare il file Lua
non sostituisce le mappature già attive nei buffer. In modalità Insert,
`Ctrl+Spazio` deve risultare associato a `Show, Show Documentation, Hide Documentation`
nel risultato di `:verbose imap <C-Space>`.

| Scorciatoia | Azione |
| --- | --- |
| `Ctrl+Spazio` | Apre il completamento; a menu aperto mostra/nasconde la documentazione |
| `K` (Normal) | Apre la documentazione LSP del simbolo sotto il cursore |
| `Ctrl+n` / `Ctrl+p` | Seleziona il suggerimento successivo/precedente |
| `Tab` | Conferma il suggerimento; negli snippet passa al campo successivo |
| `Shift+Tab` | Torna al campo precedente dello snippet |
| `Ctrl+e` | Chiude il completamento |
| `Ctrl+f` / `Ctrl+b` | Scorre la documentazione |
| `<leader>ca` (Normal/Visual) | Mostra le azioni LSP sul cursore o sulla selezione |
| `<leader>rr` | Rinomina il simbolo tramite LSP |
| `<leader>rg` | Organizza gli import, se supportato dal server |

La documentazione del simbolo richiede un server LSP collegato che supporti hover.
Per le voci del completamento, il server può fornire solo il tipo o la firma:
in quel caso Blink mostra quelle informazioni senza una descrizione aggiuntiva.

Nei campi degli snippet i suggerimenti non vengono preselezionati: Tab passa
al campo successivo. Per accettare un completamento nel campo, selezionalo
prima con Ctrl+n/Ctrl+p e premi Tab.

`mini.pairs` chiude automaticamente parentesi e virgolette in modalità Insert.
Digitare la chiusura già presente la supera; Backspace elimina una coppia vuota
e Invio tra parentesi abbinate apre una riga interna.

Prima di scrivere import o membri mancanti, prova `<leader>ca`: le azioni
dipendono dal server di linguaggio e dal codice sotto il cursore. In Dart il
completamento delle chiamate a funzione è abilitato tramite flutter-tools.

## Formattazione

| Scorciatoia | Azione |
| --- | --- |
| `<leader>fm` | Formatta il documento o la selezione |
| `<leader>tf` | Attiva/disattiva la formattazione al salvataggio nel buffer corrente |
| `<leader>fi` | Mostra formatter disponibili ed eventuali problemi (`ConformInfo`) |

La formattazione al salvataggio è attiva per impostazione predefinita, eccetto
per C, C++, Objective-C, CUDA e Proto. Il toggle vale per il buffer aperto;
la formattazione manuale rimane disponibile anche quando il toggle è spento.
Gli errori dei formatter vengono notificati. La pulizia degli spazi è affidata
ai formatter: non viene eseguita una sostituzione indiscriminata su tutti i file.

## Diagnostiche

`[d` / `]d` vanno alla diagnostica precedente/successiva; `[e` / `]e` filtrano
solo gli errori, `[w` / `]w` includono avvisi ed errori. È possibile anteporre
un conteggio, per esempio `3]d`. `<leader>vd` mostra i dettagli della riga.

## Flutter

Queste scorciatoie sono disponibili nei buffer Dart:

| Scorciatoia | Azione |
| --- | --- |
| `<leader>fr` | Avvia l'app |
| `<leader>fh` | Hot reload |
| `<leader>fR` | Hot restart |
| `<leader>fq` | Ferma l'app |
| `<leader>fd` | Scegli dispositivo |
| `<leader>fe` | Scegli emulatore |
| `<leader>fo` | Mostra/nascondi l'albero dei widget |
| `<leader>fl` | Riavvia il server Dart |

Le guide dei widget sono abilitate. Il server Dart è gestito da flutter-tools;
Mason gestisce gli altri server tramite l'API nativa `vim.lsp.config`.

## Git

`[c` / `]c` navigano tra le modifiche. `<leader>ghp` mostra l'anteprima del
blocco corrente; `<leader>ghs` lo aggiunge allo staging oppure lo rimuove se
è già staged. In modalità Visual, `<leader>ghs` opera sulle righe selezionate.
`<leader>gs` apre lo stato Git; `<leader>gd` confronta il file con HEAD.

## Snippet Dart

Gli snippet personali si trovano in `snippets/dart.lua` e compaiono nel
completamento di Blink. Scegli lo snippet con Tab; Tab e Shift-Tab navigano
tra i campi. Le classi ripetute vengono aggiornate insieme.

| Abbreviazione | Contenuto |
| --- | --- |
| `stless` | StatelessWidget con costruttore |
| `stful` | StatefulWidget con classe State |
| `ctor` | Costruttore con parametro nominato obbligatorio |
| `screen` | Schermata con Scaffold e AppBar |
| `afn` | Funzione asincrona con tipo, nome, parametri e corpo modificabili |
| `trya` | Blocco try/catch per un'operazione asincrona; rilancia l'errore di default |
| `dgroup` | Gruppo di test con setUp, tearDown e primo test |
| `dtest` | Test unitario |
| `wtest` | Test di widget |

Aggiungi gli import Flutter/test necessari al file; gli snippet non li inseriscono.

## Modifiche esterne

I file visibili vengono controllati ogni secondo in modalità normale o terminale,
e al ritorno nell'editor. I buffer con modifiche non salvate vengono preservati.
