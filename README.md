
<img width="1407" height="745" alt="Captura de tela 2025-11-30 170617" src="https://github.com/user-attachments/assets/8d8788ab-2d04-4934-bd68-98f9f9cd5045" />

# Global Transform Editor

Adiciona campos de **Global Position** e **Global Rotation** no topo do Inspector para qualquer `Node3D`.

## Funcionalidades

- **Visualizar/Editar:** Modifique coordenadas globais absolutas usando sliders padrão.
- **Copiar/Colar Inteligente:** Use os ícones para transferir transforms globais entre nós.
  - **Copiar:** Salva a string `Vector3(...)` na área de transferência do sistema.
  - **Colar:** Lê o texto `Vector3(...)` da área de transferência e aplica o valor (suporta Desfazer/Refazer).
- **Performance:** Seções retráteis. Para de processar quando fechadas ou quando o nó não está selecionado.

## Como Usar

1. Selecione um `Node3D`.
2. Expanda **Global Position** ou **Global Rotation** no topo do Inspector.
3. Arraste os sliders para modificar os valores.
4. Use os **ícones de Copiar/Colar** para transferir valores entre objetos ou scripts.

## Instalação

1. Coloque a pasta do plugin em `res://addons/`.
2. Ative em **Projeto > Configurações do Projeto > Plugins**.
