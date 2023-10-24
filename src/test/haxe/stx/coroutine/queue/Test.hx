package stx.coroutine.queue;

using stx.Nano;
using stx.Test;
using stx.Log;
using stx.Coroutine;
using stx.Stream;
using stx.coroutine.Queue;

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
    final qI                = __.coroutine().queue().Queue.Make(queueI);
    final qIA               = qI.provide(QueueStart)
                               .provide(QueueEnque(1))
                               .provide(QueueDeque())
                               .provide(QueueStop);

    var queueII:IQueue<Int>  = queues.QueueFactory.instance.createQueue(queues.QueueFactory.SIMPLE_QUEUE);
    final qII                = __.coroutine().queue().Queue.Make(queueII);
    final qIIA               = qII.provide(QueueStart)
                              .provide(QueueDeque(null,true))
                              .provide(QueueEnque(10))
                              .provide(QueueStop);
                          

    var stopped = 0;
    
    final l = qIA.relate( //Handler for intermediate O values
      o -> {
        trace(o);
        return __.report();
      }
    ).derive(() -> Right(Stop))//If asked for input for Wait
     .complete(r -> {trace(r);})//use R value, in this case Nada
     .toExecute();//create Fletcher

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

     //bind Executes and run
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