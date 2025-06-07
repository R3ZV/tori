# Tori

A terminal BitTorrent protocol client written in Hare to test the language.

BitTorrent is a peer-to-peer file sharing protocol used for distributing large
amounts of data.

Idea from [Build your own BitTorrent](https://app.codecrafters.io/courses/bittorrent/overview)
so the todo is inspired from their roadmap:

# Todo

Core:
- [x] Decode bencoded strings
- [x] Decode bencoded integers
- [x] Decode bencoded lists
- [ ] Decode bencoded dictionaries
- [ ] Parse torrent file
- [ ] Calculate info hash
- [ ] Piece hashes
- [ ] Discover peers
- [ ] Peer handshake
- [ ] Download a piece
- [ ] Download the whole file

Magnet Links:
- [ ] Parse magnet link
- [ ] Announce extension support
- [ ] Send extension handshake
- [ ] Receive extension handshake
- [ ] Request metadata
- [ ] Receive metadata
- [ ] Download a piece
- [ ] Download the whole file
