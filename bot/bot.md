# **BOT no Android usando o Termux**

Como rodar o bot em segundo plano no Android e configurar o dispositivo como um servidor para que o bot seja executado automaticamente ao ligar o celular.

No Android: **Play Store** ou **F-Droid** -> Baixe **Termux**, **Termux:Boot**

---

## Termux
**Atualiza o sistema e instala as bibliotecas necessárias para rodar script**
```bash

	pkg update && pkg upgrade -y

	pkg install python libsodium termux-services termux-api -y

	pip install -U discord.py

```

**Acessar os arquivos do armazenamento do celular**
```bash

	termux-setup-storage

```

**Rodar um script em segundo plano**
```bash

	termux-wake-lock

```
Marque a opção Nenhuma restrição na bateria 

---

## Personalizar o Termux
```bash
	
	git clone https://github.com/izxqux/dotfiles.git
	cd dotfiles/termux/

	chmod +x termux.sh
	
	./termux.sh -i
	
	ou
	
	source termux.sh -i

```
Se não usar personalização

mkdir -p "$HOME/.script"

```bash

	cp -av aiph/bot/boasvindasbot.py "$HOME/.script"
	
	chmod +x "$HOME/.script/boasvindasbot.py

```

Se não usar personalização

mkdir -p "$HOME/.termux/boot/"

cp -av aiph/bot/iniscript.sh "$HOME/.termux/boot/"

```bash
	
	chmod +x "$HOME/.termux/boot/iniscript.sh
	
	"$HOME/.termux/boot/iniscript.sh"

```

No celular
Configurações / Apps / Permissões / Início automático em segundo plano

Ativa: Termux e Termux:Boot

E renicie o celular
Abra Termux:BOOT, apenas uma vez

---