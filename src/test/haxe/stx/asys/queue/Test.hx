package stx.asys.queue;

using stx.Nano;
using stx.Test;
using stx.Log;
using stx.ASys;
using stx.asys.Queue;

@stx.test.async
class Test extends TestCase{
  static public function main(){
    __.logger().global().configure(
          logger -> logger.with_logic(
            logic -> logic.or(
              logic.tags(
                []
                //["stx/stream","eu/ohrmun/fletcher"]
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
                               .provide(QueueRequest())
                               .provide(QueueStop);

    var queueII:IQueue<Int>  = queues.QueueFactory.instance.createQueue(queues.QueueFactory.SIMPLE_QUEUE);
    final qII                = __.asys().queue().Queue.Make(queueII);
    final qIIA               = qII.provide(QueueStart)
                              .provide(QueueRequest())
                              .provide(QueueEnque(10))
                              .provide(QueueStop);
                          

    var stopped = 0;
    function handler(self){
      //trace(self);
      switch(self){
        case Emit(o,next) :
          //trace(o);
          handler(next);
        case Wait(tran)   :
          //trace('wait');
        case Hold(held)   :
          //trace('held $held');
          held.handle(
            (x) -> {
              //trace('future $x');
              handler(x);
            }
          );
        case Halt(r)      :
          trace(r);
          stopped = stopped + 1;
          if(stopped == 2){
            async.done();
          }
      }
    }
    handler(qIA);
    handler(qIIA);


  }
}