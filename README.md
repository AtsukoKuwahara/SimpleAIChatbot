# **OrangeBot: A Simple AI Chatbot**

OrangeBot is an iOS application built using **SwiftUI**, leveraging advanced AI models like `llama3.2`, `llama3.1`, and `mistral` to provide chatbot responses. The app communicates with a **local API server** powered by **Ollama** for processing user queries.

---

## **Features**

- **Multi-Model Support**: Choose between AI models such as `llama3.2`, `llama3.1`, and `mistral`.
- **Customizable Settings**: Configure chatbot behavior with parameters like:
  - **Temperature**: Controls response creativity.
  - **Seed**: Ensures deterministic outputs.
  - **Top_k**: Influences response diversity.
- **Chat History**: Save conversations locally for offline access.
- **Markdown Rendering**: Display rich-text formatted responses.
- **Offline Access**: Access saved chat history using `UserDefaults`.

---

## **Screenshots**
```html
<div align="center">
<img src="assets/chat_screen_image.jpg" alt="Chat Screen" width="300"/>  
<img src="assets/archive_screen_image.jpg" alt="Archive Screen" width="300"/>  
<img src="assets/detail_screen_image.jpg" alt="Detail Screen" width="300"/>  
<img src="assets/settings_screen_image.jpg" alt="Settings Screen" width="300"/>  
</div>
```
---

## **Requirements**

- **Xcode**: Version 12 or later  
- **iOS**: Version 17.0 or later  
- **Swift**: Version 5.3 or later  
- **Ollama Local Server**: [Download from Ollama](https://ollama.com/search)

---

## **Getting Started**

### **Prerequisites**

1. Install the latest version of **Xcode**.
2. Download and install the **Ollama Local Server** by visiting the [Ollama website](https://ollama.com/search).  
   This server hosts and manages the AI models used in the app.
3. Download your preferred AI models using the Ollama command-line tool. For example:
    ```bash
    ollama pull llama3.1
    ```

---

### **Installation**

1. **Clone the repository**:
    ```bash
    git clone https://github.com/AtsukoKuwahara/SimpleAIChatbot.git
    cd SimpleAIChatbot
    ```

2. **Open the project in Xcode**:
    ```bash
    open SimpleAIChatbot.xcodeproj
    ```

3. **Run the Ollama server**:
    ```bash
    ollama serve
    ```

4. **Build and run the app**:
    - Select your target device or simulator in Xcode and click **Run**.

---

## **Backend Service**

OrangeBot interacts with a **local API server** managed by Ollama. This server processes API requests and generates responses using the selected AI model.

### **Example API Request**

Endpoint: `/api/chat`  
```json
{
  "model": "llama3.1",
  "messages": [
    { "role": "user", "content": "Why is the sky blue?" }
  ],
  "options": {
    "seed": 42,
    "temperature": 0.7,
    "top_k": 40
  },
  "stream": false
}
```
For more details on Ollama’s API, see the [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md).

---

## **Usage**

1. **Select the Model**: Choose from `llama3`, `llama3.1`, or `mistral` using the model picker at the top of the chat screen.
2. **Ask a Question**: Type your query in the text field and press **Send**.
3. **View Responses**: AI-generated responses appear below the input field. Access chat history in the **Archive** tab.
4. **Adjust Settings**: Open the **Settings View** to customize parameters like temperature, seed, and top_k.
5. **Detailed View**: Tap an entry in the Archive to view the complete conversation and model details.

---

## **Code Structure**

```
SimpleAIChatbot
├── App
│   ├── SimpleAIChatbotApp.swift     # Entry point of the application
│   ├── ContentView.swift            # Main view containing the TabView
│   └── SettingsView.swift           # Provides chatbot parameter customization
├── Views
│   ├── ChatView.swift               # Handles user input and displays AI responses
│   ├── ChatDetailView.swift         # Shows detailed conversation entries
│   ├── ArchiveView.swift            # Displays a list of archived chats
│   └── LoadingView.swift            # Loading indicators for network calls
├── Models
│   └── ChatEntry.swift              # Represents a single chat interaction
└── Services
    ├── NetworkService.swift         # Handles HTTP requests to the backend
    └── ChatViewModel.swift          # Manages chat state and persistence
```

---

## **Customization**

1. **Add New Models**:  
   Use the `ollama pull` command to download additional models:
    ```bash
    ollama pull <model_name>
    ```

2. **Modify Default Settings**:  
   Update the default parameter values in `SettingsView.swift`.

3. **Change Backend URL**:  
   Modify the API endpoint in `NetworkService.swift` to match your server configuration.

---

## **Additional Resources**

- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)  
- [Download AI Models](https://ollama.com/search)  
