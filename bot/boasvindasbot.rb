#
# => @utor XzXquX
# => Ruby
# => Biblioteca: discordrb -> https://www.rubydoc.info/gems/discordrb
#
# => Este bot é projetado para enviar uma mensagem de boas-vindas em um canal específico do Discord, sempre que um novo membro entra no servidor
#
# => Instruções:
#
# => 1 -> Certifique-se de configurar as intents no Discord Developer Portal
# => 2 -> Substitua os valores das variáveis: USERAIPHCHANNEL e USERAIPHTOKEN pelos IDs correspondentes ao seu servidor
#

# gem install discordrb

require 'discordrb'
require 'set'

#Seu ID do canal
USERAIPHCHANNEL = 1234567890

#Seu token
USERAIPHTOKEN = ENV["DISCORDBOT_TOKEN_BOASVINDAS"] || "Aqui seu TOKEN"

#Salvar os IDs/Nomes dos usuários
BOASVINDASDB = "boasvindas.txt"

#Salvar os LOGS
BOASVINDASLOG = "boasvindas.log"

#Carregar usuários na inicialização do bot
$usuariosCarregados = Set.new


def limparTela
	case RUBY_PLATFORM
		when /mswin|mingw|cygwin/ #Win
			system("cls")
		when /linux|darwin/ #Linux ou MacOS
			system("clear")
		else
			puts "[-] Limpeza de tela não suportada neste neste sistema!"
	end
end

#Verifica se arquivo existe, se não cria
def veriArquivo
	unless File.exist?(BOASVINDASDB)
		File.open(BOASVINDASDB, 'w') {}
		puts "[LOG] Arquivo: #{BOASVINDASDB}, Criado!"
		registrarLog(puts "[LOG] Arquivo: #{BOASVINDASDB}, Criado!")
	end

	unless File.exist?(BOASVINDASLOG)
		File.open(BOASVINDASLOG, 'w') {}
		puts "[LOG] Arquivo: #{BOASVINDASLOG}, Criado!"
		registrarLog("[LOG] Arquivo: #{BOASVINDASLOG}, Criado!")
	end
end

#Carregar os IDs/nomes, dos usuários do arquivo para memória
def carreUsuario
	veriArquivo #Arquivo existe?
	$usuariosCarregados = Set.new(File.readlines(BOASVINDASDB).map { |line| line.split('|').first.strip } ) #Var global, Lendo o arquivo, ID | Nome | Data -> line.split('|').first.strip: Extração dos IDs
	puts "[LOG] #{BOASVINDASLOG}, Usuários Carregados [+]"
	registrarLog("[LOG] #{BOASVINDASLOG}, Usuários Carregados [+]")
end

#Salvar um novo usuário no arquivo
def salvarUsuario(userId, userName)
	userDate = Time.now.strftime("%Y-%m-%d %H:%M:%S") #Ano-Mês-Dia Hora:Minuto:Segundo

	#Add logEntry no arquivo
	logEntry = "#{userId} | #{userName} | #{userDate}"
	File.open(BOASVINDASDB, 'a') do |file|
		file.puts(logEntry)
	end

	$usuariosCarregados.add(userId) #Na var global, add userId
	puts "[LOG] Usuário: #{userName} | ID: #{userId} | Datas: #{userDate}"
	registrarLog("[LOG] Usuário: #{userName} | ID: #{userId} | Datas: #{userDate}")
end


#Registrar logs
def registrarLog(msg)
	userDate = Time.now.strftime("%Y-%m-%d %H:%M:%S") #Ano-Mês-Dia Hora:Minuto:Segundo

	File.open(BOASVINDASLOG, 'a') do |file|
		file.puts("[LOG] [#{userDate}] -> [#{msg}]") #Registra datas, msg
	end
end


#Verificar conectividade e reconectar automaticamente
def verificarConectividade(bot)
	Thread.new do
		loop do
			sleep(300) #Aguarda 5 minutos -> 180 segundos: Aguarda 3 minutos
			unless bot.connected?
				puts "[-] BOT: Desconectado! Tentando reconectar!"
				registrarLog("[-] BOT: Desconectado! Tentando reconectar!")
				begin
					bot.run(true) #Força uma nova conexão
				rescue StandardError => error
					puts "Erro: ao reconectar: #{error.message}"
					registrarLog("Erro: ao reconectar: #{error.message}")
					break
				end
			end
		end
	end
end

def iniciarBot
		bot = Discordrb::Bot.new token: USERAIPHTOKEN, intents: [:server_members, :messages] #Detectar novos membros e enviar mensagens, bot que verificar conectividade e reconectar automaticamente

		bot.ready do |event|
			puts "BOT #{event.bot.profile.username} ON!"
			registrarLog("BOT #{event.bot.profile.username} ON!")
			verificarConectividade(bot) #bot 
		end

		bot.member_join do |event|
			#Canal ID
			channel = bot.channel(USERAIPHCHANNEL)
			if( channel.nil? )
				puts "Canal não encontrado!"
				registrarLog("Canal não encontrado!")
				next
			end

			#Verifica se o user já recebeu a msg de boasvindas
			if $usuariosCarregados.include?(event.user.id.to_s) #Transforma id do user em str: event.user.id.to_s, $usuariosCarregados.include?: verifica se o user já existe, var global
				puts "Usuário: #{event.user.name}, Recebeu a mensagem!"
				registrarLog("Usuário: #{event.user.name}, Recebeu a mensagem!")
				next
			end

			#Mensagem de boas-vindas
			boasvindas = Discordrb::Webhooks::Embed.new(
				title: "Bem-vindo(a) ao AIPH!",
				description: "🤖 Olá #{event.user.mention}, seja bem-vindo(a) ao AIPH!\n\nAqui falamos sobre:\n\t🌐 | IDIOMAS\n\t🎶 | INSTRUMENTOS\n\t💻 | TECNOLOGIA\n\n-> Leia as [regras](https://discord.com/channels/1339820203743248451/1341923822734934017)!",
				color: 0xFF0000, #Cor vermelha opcional
			)

			#Adiciona imagem de perfil do usuário, se disponível
			if event.user.avatar_url
				boasvindas.thumbnail = { url: event.user.avatar_url }
			end

			#Enviado a mensagem de boas-vindas
			channel.send_embed("", boasvindas)

			salvarUsuario(event.user.id.to_s, event.user.name) #Salva id, nome do user no arquivo

		end

	begin
		loop do
			bot.run
		end
	rescue StandardError => error
		puts "Ocorreu um erro inesperado: #{error.message}"
		registrarLog("Ocorreu um erro inesperado: #{error.message}")
	rescue Interrupt
		puts "BOT, foi interrompido [CTRL] + [C], Encerrando!"
		registrarLog("BOT, foi interrompido [CTRL] + [C], Encerrando!")
	end
end

#Se arquivo, for alterado manualmente, pode chamar, recarregamento manual, usando o comando: /atualizarboasvindasdb
carreUsuario() #Carregar os IDs/nomes, dos usuários do arquivo para memória, o arquivo é lido uma vez apenas

limparTela
puts "Iniciando BOT!"
registrarLog("Iniciando BOT!")
iniciarBot()
