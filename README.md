# Infraestrutura Selenoid

Este projeto utiliza o [Selenoid Grid](https://aerokube.com/selenoid/latest/) para executar testes web automatizados em paralelo, utilizando o Docker como única dependência (o Docker já vem com o Compose integrado).

## Requisitos

- Docker

## Instruções para Iniciar

### Linux

1. Acesse a pasta **bin** e torne o script executável:
   ```sh
   sudo chmod a+x build-linux.sh
   ```
2. Execute o script:
   ```sh
   ./build-linux.sh
   ```

### Windows

- Execute diretamente o script **build-windows.bat** na pasta **bin**.

Após a execução, abra o navegador e acesse [http://localhost:8080](http://localhost:8080) para visualizar a interface do Selenoid.

---

## Explicação da Infraestrutura Docker

A seguir, o arquivo de configuração Docker com comentários explicativos:

```yaml
version: '4.0'

services:

  selenoid-ui:
    image: aerokube/selenoid-ui:1.10.11     # Imagem da interface Selenoid UI
    container_name: selenoid-ui             # Nome do container para referência
    ports:
      - "8080:8080"                         # Mapeia a porta 8080 para acesso via navegador
    environment:
      TZ: "America/Sao_Paulo"               # Define o fuso horário
    dns: 8.8.8.8                            # Configuração de DNS
    logging:
      driver: "json-file"
      options:
        max-size: "10m"                     # Tamanho máximo do arquivo de log
        max-file: "3"                       # Número máximo de arquivos de log
    command: >
      --selenoid-uri http://selenoid:4444 --allowed-origin *  # Conecta ao serviço Selenoid e permite acesso de todas as origens
    networks:
      - selenoid

  selenoid:
    image: aerokube/selenoid:1.11.3         # Imagem do Selenoid
    container_name: selenoid               # Nome do container do Selenoid
    ports:
      - "4444:4444"                         # Mapeia a porta 4444 para comunicação WebDriver
    volumes:
      - "./browsers/browsers.json:/etc/selenoid/browsers.json"  # Monta o arquivo de configuração dos navegadores
      - "/var/run/docker.sock:/var/run/docker.sock"             # Permite que o Selenoid gerencie containers via Docker
    environment:
      TZ: "America/Sao_Paulo"               # Define o fuso horário
    dns: 8.8.8.8                            # Configuração de DNS
    logging:
      driver: "json-file"
      options:
        max-size: "10m"                     # Tamanho máximo do arquivo de log
        max-file: "3"                       # Número máximo de arquivos de log
    command: >
      -conf /etc/selenoid/browsers.json     # Especifica o arquivo de configuração dos navegadores
      -container-network selenoid            # Define a rede utilizada pelos containers dos navegadores
      -limit 10                              # Limita a 10 sessões simultâneas
    networks:
      - selenoid

networks:
  selenoid:
    external: true                          # Utiliza uma rede externa chamada "selenoid"
```

---

## Configuração dos Navegadores

O arquivo `browsers.json`, localizado na pasta **browsers**, define os navegadores que o Selenoid gerencia:

```json
{
    "chrome": {
        "default": "latest",                         // Versão padrão do Chrome
        "versions": {
            "latest": {
                "image": "selenoid/chrome:latest",     // Imagem Docker para o Chrome
                "port": "4444",                        // Porta utilizada pelo WebDriver
                "tmpfs": {
                    "/tmp": "size=512m"                // Configuração do sistema de arquivos temporário
                },
                "shmSize": 1073741824                  // Tamanho da memória compartilhada (1GB)
            }
        }
    },
    "firefox": {
        "default": "latest",                         // Versão padrão do Firefox
        "versions": {
            "latest": {
                "image": "selenoid/firefox:latest",    // Imagem Docker para o Firefox
                "port": "4444",                        // Porta utilizada pelo WebDriver
                "path": "/wd/hub",                     // Endpoint padrão do WebDriver
                "tmpfs": {
                    "/tmp": "size=512m"                // Configuração do sistema de arquivos temporário
                },
                "shmSize": 1073741824                  // Tamanho da memória compartilhada (1GB)
            }
        }
    }
}
```
