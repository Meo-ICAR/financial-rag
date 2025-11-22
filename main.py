import os
import glob
from dotenv import load_dotenv

# Loaders specifici
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
# --- MODIFICA 1: Importa le classi Google invece di OpenAI ---
from langchain_google_genai import GoogleGenerativeAIEmbeddings, ChatGoogleGenerativeAI
from langchain_community.vectorstores import FAISS
from langchain.chains import RetrievalQA

load_dotenv()

def load_document(file_path):
    """""
    Factory function che sceglie il loader corretto in base all'estensione.
    Simile a un Service Provider in Symfony/Laravel.
    """""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.pdf':
        print(f"  -> Loading PDF: {file_path}")
        return PyPDFLoader(file_path).load()
        
    elif ext == '.xml':
        print(f"  -> Loading XML: {file_path}")
        # Per i report finanziari come Cerved.xml, mantenere i tag è utile.
        # L'LLM userà i tag <Sales>, <Ebitda> per capire il contesto del numero.
        return TextLoader(file_path, encoding='utf-8').load()
        
    else:
        print(f"  -> Formato non supportato: {ext}")
        return []

def main():
    # 1. SETUP E INGESTION MULTI-FILE
    # Invece di un singolo file, cerchiamo tutti i pdf e xml nella cartella
    documents = []
    files = glob.glob("*.pdf") + glob.glob("*.xml")

    if not files:
        print("Errore: Nessun file .pdf o .xml trovato nella directory corrente.")
        return

    print("--- 1. Caricamento documenti (Ingestion) ---")
    for file_path in files:
        docs = load_document(file_path)
        documents.extend(docs)

    if not documents:
        print("Nessun contenuto estratto.")
        return

    # 2. CHUNKING
    # Per l'XML finanziario, un chunk_size un po' più ampio aiuta a tenere 
    # insieme i blocchi di dati correlati (es. tutto il conto economico).
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=2000,  # Aumentato per catturare blocchi XML più grandi
        chunk_overlap=200
    )
    splits = text_splitter.split_documents(documents)
    print(f"Creati {len(splits)} frammenti totali da {len(files)} file.")

    # 3. EMBEDDING & VECTOR STORE
    print("--- 2. Indicizzazione (Embedding) ---")
# --- MODIFICA 2: Usa il modello di embedding di Google ---
    # "models/embedding-001" è lo standard attuale
    embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
    vectorstore = FAISS.from_documents(splits, embeddings)
    retriever = vectorstore.as_retriever()

# 4. LLM (Gemini)
    # --- MODIFICA 3: Usa Gemini 1.5 Flash ---
    # È veloce, economico e ottimo per tasks analitici
    llm = ChatGoogleGenerativeAI(
        model="gemini-1.5-flash", 
        temperature=0,
        convert_system_message_to_human=True # A volte necessario per compatibilità
    )

    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        retriever=retriever,
        chain_type="stuff",
        return_source_documents=True
    )

    # 5. INTERFACCIA
    print(f"\n--- RAG Finanziario Attivo su {len(files)} documenti ---")
    print("Esempio query: 'Qual è il fatturato (Sales) nel report Cerved?' o 'Chi sono gli amministratori?'")
    
    while True:
        query = input("\nDomanda (o 'exit'): ")
        if query.lower() in ["exit", "esci", "quit"]:
            break
            
        response = qa_chain.invoke({"query": query})
        
        print(f"\nRisposta:\n{response['result']}")
        
        # Debug: Vediamo quale file ha usato per rispondere (utile per verifica)
        source_file = response['source_documents'][0].metadata['source']
        print(f"\n[Fonte dati: {source_file}]")

if __name__ == "__main__":
    main()
