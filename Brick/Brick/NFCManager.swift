import Foundation
import Combine

#if canImport(CoreNFC)
import CoreNFC
#endif

#if canImport(CoreNFC)

class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    static let shared = NFCManager()
    static let tagURL = URL(string: "touchgrass://toggle")!

    @Published var lastScanDate: Date?
    @Published var isScanning = false

    private var session: NFCNDEFReaderSession?
    private var onTagRead: (() -> Void)?
    private var writeCompletion: ((Bool) -> Void)?
    private var isWriting = false

    override init() { super.init() }

    func scan(onRead: @escaping () -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else { return }
        self.onTagRead = onRead
        session = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the tag"
        session?.begin()
        isScanning = true
    }

    func programTag(completion: @escaping (Bool) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(false)
            return
        }
        let newSession = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: false)
        newSession.alertMessage = "Hold your iPhone near the NFC tag to program it"
        self.writeCompletion = completion
        self.isWriting = true
        newSession.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            self.isWriting = false
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let url = record.wellKnownTypeURIPayload(), url.scheme == "touchgrass" {
                    DispatchQueue.main.async {
                        self.lastScanDate = Date()
                        self.onTagRead?()
                    }
                    session.invalidate()
                    return
                }
            }
        }
        session.invalidate(errorMessage: "Not a valid TouchGrass tag.")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag found.")
            return
        }
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            if self.isWriting {
                self.writeToTag(tag, session: session)
            } else {
                self.readTag(tag, session: session)
            }
        }
    }

    private func readTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { message, error in
            guard let message = message else {
                session.invalidate(errorMessage: "Couldn't read tag.")
                return
            }
            for record in message.records {
                if let url = record.wellKnownTypeURIPayload(), url.scheme == "touchgrass" {
                    DispatchQueue.main.async {
                        self.lastScanDate = Date()
                        self.onTagRead?()
                    }
                    session.alertMessage = "TouchGrass detected!"
                    session.invalidate()
                    return
                }
            }
            session.invalidate(errorMessage: "Not a valid TouchGrass tag.")
        }
    }

    private func writeToTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.queryNDEFStatus { status, capacity, error in
            guard status == .readWrite else {
                session.invalidate(errorMessage: "Tag is not writable.")
                self.writeCompletion?(false)
                return
            }
            let uriPayload = NFCNDEFPayload.wellKnownTypeURIPayload(url: NFCManager.tagURL)!
            let message = NFCNDEFMessage(records: [uriPayload])
            tag.writeNDEF(message) { error in
                if let error = error {
                    session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                    self.writeCompletion?(false)
                } else {
                    session.alertMessage = "Tag programmed!"
                    session.invalidate()
                    self.writeCompletion?(true)
                }
                DispatchQueue.main.async { self.isWriting = false }
            }
        }
    }
}

#else

class NFCManager: ObservableObject {
    static let shared = NFCManager()
    static let tagURL = URL(string: "touchgrass://toggle")!

    @Published var lastScanDate: Date?
    @Published var isScanning = false

    func scan(onRead: @escaping () -> Void) {}
    func programTag(completion: @escaping (Bool) -> Void) { completion(false) }
}

#endif
