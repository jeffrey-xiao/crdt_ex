# crdt_ex

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://travis-ci.org/jeffrey-xiao/crdt_ex.svg?branch=master)](https://travis-ci.org/jeffrey-xiao/crdt_ex)
[![codecov](https://codecov.io/gh/jeffrey-xiao/crdt_ex/branch/master/graph/badge.svg)](https://codecov.io/gh/jeffrey-xiao/crdt_ex)

A library of Conflict-Free Replicated Data Types (CRDTs) written in pure Elixir.

CRDTs are data structures which can be replicated across multiple computers in a network, where the
replicas can be updated independently and concurrently without coordination between the replicas.

## References

 - [A Comprehensive Study of Convergent and Commutative Replicated Data Types](https://link.springer.com/chapter/10.1007%2F978-3-642-24550-3_29)
 > Shapiro, Marc, Nuno Preguiça, Carlos Baquero, and Marek Zawirski. 2011. "Conflict-Free Replicated Data Types." In _Stabilization, Safety, and Security of Distributed Systems_, edited by Xavier Défago, Franck Petit, and Vincent Villain, 386–400. Berlin, Heidelberg: Springer Berlin Heidelberg.

## License

`crdt_ex` is dual-licensed under the terms of either the MIT License or the Apache License (Version
2.0).

See [LICENSE-APACHE](LICENSE-APACHE) and [LICENSE-MIT](LICENSE-MIT) for more details.
