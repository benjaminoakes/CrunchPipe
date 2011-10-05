CrunchPipe
==========

CrunchPipe is a library for creating and coordinating modular
computation pipelines. Computation can take place in parallel and data
sources are kept separate from the computation itself leading to
modular and maintainable programs.

The Basics
----------

CrunchPipe utilized computation pipelines connected to streams to
model the processing of data.

`/--------------\
| Input Stream |
\--------------/

    ||
    \/

/----------\
| Pipeline |
|----------|
| Op 1     |
|----------|
| Op 2     |
|----------|
| Op 3     |
\----------/

    ||
    \/

/---------------\
| Output Stream |
\---------------/
`
Streams
----------

Streams are the sources and sinks of data. You create a stream and add
elements to it. All pipelines connected to the stream will be alerted
when data is added to a stream. Pipelines also write their finished
results to a stream which can, optionally, have other pipelines
connected to it. Since streams are also data sinks, streams can be
provided with the means to save the results of computation in an
abstract and general way.

Pipelines
----------

Pipelines represent computational processes. When a pipeline is
created, you can bind an arbitrary number of transformations to it in
the form of blocks to create an "assembly line" of operations to be
performed on data. Pipelines are connected to streams and will be
notified when new data is available. Each new element from the stream
will be run through the bound operations in the order in which they
were bound to the pipeline. However, the elements obtained from
streams can be processed in parallel (threads or processes) thus
leading to performance improvements. Since the order of operation
application is preserved, it is the elements from the stream which are
processed in parallel. The parallelism is encapsulated within the
pipeline thus freeing the developer from the concerns traditionally
associated with writing parallel code.


ToDo
----------

* Get specs passing, dammit
* Improved DSL
