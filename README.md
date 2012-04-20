Vertices
========


by Scott McCoid, Jimmy O'Neill and Sisi Sun

Vertices is a realtime networked iPhone application for collaborative music-making. Users create the vertices of a time-varying undirected graph (called a "sound object") via multitouch input, and the graph parameters are used to synthesize musical output. Users can then record these sound objects and send them to their peers by making a "toss" gesture in the direction of the peer to whom they would like to send their object. When a performer receives an object, they then have the ability to replay, loop, modify, and send the modified object to another peer.   

Dependencies
------------

- Vertices uses pd-for-ios (http://gitorious.org/pdlib/pd-for-ios) for synthesis.


Issues
------ 

- We use a p2p Bluetooth network through the GameKit framework. While this is fairly reliable for 2 peers, it becomes less reliable for >2 peers.
    