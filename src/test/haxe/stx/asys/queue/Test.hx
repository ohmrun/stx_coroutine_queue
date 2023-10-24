package stx.asys.queue;

using stx.Nano;
using stx.Test;
using stx.Log;
using stx.ASys;
using stx.Stream;
using stx.asys.Queue;

@stx.test.async
class Test extends TestCase{
  static public function main(){
    __.logger().global().configure(
          logger -> logger.with_logic(
            logic -> logic.or(
              logic.tags(
                []
                //["stx/stream/scheduler"]
              )
            )
          )
        );
    __.test().run(
      [
        new Test()
      ],[]
    );
  }
  public function test(async:stx.Async){
    var queueI:IQueue<Int>  = queues.QueueFactory.instance.createQueue(queues.QueueFactory.SIMPLE_QUEUE);
    final qI                = __.asys().queue().Queue.Make(queueI);
    final qIA               = qI.provide(QueueStart)
                               .provide(QueueEnque(1))
                               .provide(QueueGet())
                               .provide(QueueStop);

    var queueII:IQueue<Int>  = queues.QueueFactory.instance.createQueue(queues.QueueFactory.SIMPLE_QUEUE);
    final qII                = __.asys().queue().Queue.Make(queueII);
    final qIIA               = qII.provide(QueueStart)
                              .provide(QueueGet(null,true))
                              .provide(QueueEnque(10))
                              .provide(QueueStop);
                          

    var stopped = 0;
    
    final l = qIA.relate(
      o -> {
        trace(o);
        return __.report();
      }
    ).derive(() -> Right(Stop))
     .complete(r -> {trace(r);})
     .toExecute();

     final r = qIIA.relate(
      o -> {
        trace(o);
        return __.report();
      }
    ).derive(() -> Right(Stop))
     .complete(r -> {
      trace(r);
     })
     .toExecute();

     l.and(r).deliver(
      report -> {
        report.fold(
          err -> refuse(err),
          ()  -> pass()
        );
        async.done();
      }
     ).submit();
  }
}