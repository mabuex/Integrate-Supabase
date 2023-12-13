//
//  MessagesView.swift
//  Integrate Supabase
//
//  Created by Marcus Buexenstein on 2023/12/12.
//

import SwiftUI
import Realtime

struct MessagesView: View {
    let realtime = Supabase.shared.client.realtime
    let database = Database()
    
    @Environment(Auth.self) private var auth: Auth
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var result: Result<Void, Error>?
    @State private var content: String = ""
    @State private var messages: [Message] = [Message]()
    
    @State private var socketStatus: String?
    @State private var channelStatus: String?
    @State private var publicSchema: RealtimeChannel?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let result {
                    if case .failure(let failure) = result {
                        MessageBox(failure.localizedDescription) {
                            withAnimation {
                                self.result = nil
                            }
                        }
                    }
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            HStack(alignment: .bottom) {
                            Text("Hello \(auth.profile?.username ?? "No Name")")
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                                Group {
                                    Text("Socket: \(socketStatus ?? "")")
                                    Text("Channel: \(channelStatus ?? "")")
                                }
                                .font(.caption)
                                .foregroundStyle(Color.brandSecondaryText)
                            }
                        }
                        .padding()
                        
                        LazyVStack(spacing: 15) {
                            ForEach(messages) { message in
                                chatBubble(message)
                                    .id(message.id)
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(messages.last?.id)
                        }
                        .onChange(of: messages.count) {
                            withAnimation {
                                proxy.scrollTo(messages.last?.id)
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.brandBackground)
                
                SendMessageField(text: $content) {
                    sendMessage()
                }
            }
            .background(Color.brandBackground)
            .navigationTitle("Messages")
        }
        .onAppear {
            fetchMessages()
            createSubscription()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive {
                realtime.disconnect()
            } else if newPhase == .active {
                realtime.connect()
            } else if newPhase == .background {
                realtime.disconnect()
            }
        }
    }
}

#Preview {
    MessagesView()
        .environment(Auth())
}

extension MessagesView {
    func fetchMessages() {
        Task {
            do {
                messages = try await database.fetch(.messages)
            } catch {
                withAnimation {
                    result = .failure(error)
                }
            }
        }
    }
    
    func sendMessage() {
        guard !content.isEmpty else { return }
        
        let message = Message(content: content)
        
        Task {
            do {
                _ = try await database.insert(.messages, values: message)
                content = ""
            } catch {
                withAnimation {
                    result = .failure(error)
                }
            }
        }
    }
    
    func deleteMessage(_ message: Message) {
        Task {
            do {
                try await database.delete(.messages, values: message)
            } catch {
                withAnimation {
                    result = .failure(error)
                }
            }
        }
    }
    
    // MARK: - Realtime
    func createSubscription() {
        realtime.connect()
        
        publicSchema = realtime.channel("public")
            .on("postgres_changes", filter: ChannelFilter(event: "INSERT", schema: "public")) {
                if let message = getMessage($0.payload) {
                    let index = messages.first(where: { $0.id == message.id })
                    
                    if index == nil {
                        messages.append(message)
                    }
                }
            }
            .on("postgres_changes", filter: ChannelFilter(event: "DELETE", schema: "public")) {
                if let messageID = getDeletedMessageID($0.payload) {
                    messages.removeAll(where: { $0.id == messageID })
                }
            }
        
        publicSchema?.onError { _ in channelStatus = "ERROR" }
        publicSchema?.onClose { _ in channelStatus = "Closed gracefully" }
        publicSchema?
            .subscribe { state, _ in
                switch state {
                case .subscribed:
                    channelStatus = "OK"
                case .closed:
                    channelStatus = "CLOSED"
                case .timedOut:
                    channelStatus = "Timed out"
                case .channelError:
                    channelStatus = "ERROR"
                }
            }
        
        realtime.connect()
        realtime.onOpen {
            socketStatus = "OPEN"
        }
        realtime.onClose {
            socketStatus = "CLOSE"
        }
        realtime.onError { error, _ in
            socketStatus = "ERROR: \(error.localizedDescription)"
        }
    }
    
    private func getDeletedMessageID(_ payload: Payload) -> UUID? {
        guard let data = payload["data"] else { return nil }
        
        let record = data as? [String: Any]
        let id = record?["old_record"] as? [String: Any]
        
        guard let id = id?.first else { return nil }
        guard let uuidString = id.value as? String else { return nil }
        return UUID(uuidString: uuidString)
    }
    
    private func getMessage(_ payload: Payload) -> Message? {
        guard let data = payload["data"] else { return nil }
        
        let record = data as? [String: Any]
        let dictionary = record?["record"] as? [String: Any]
        
        guard let dictionary else { return  nil }
        return try? Message(dictionary: dictionary)
    }
}

// MARK: - Components
extension MessagesView {
    @ViewBuilder
    func chatBubble(_ message: Message) -> some View {
        let isOwner = message.profileID == auth.profile?.id
        
        VStack(alignment: isOwner ? .trailing : .leading) {
            HStack(alignment: .bottom) {
                if isOwner {
                    Spacer()
                    
                    Button {
                        deleteMessage(message)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(Color.brandPrimary)
                            .font(.footnote)
                    }
                    
                    Text(message.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(Color.brandSecondaryText)
                }
                
                Text(message.content)
                    .padding()
                    .foregroundColor(Color.brandPrimaryText)
                    .background(isOwner ? Color.brandPrimary : Color.brandSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                if !isOwner {
                    Text(message.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(Color.brandSecondaryText)
                    Spacer()
                }
            }
        }
    }
}
