package stx.asys.queue;

class QueueCtr extends Clazz{
  public function Make<T>(iqueue:IQueue<T>,?buffer:SettableStoreApi<TimeStamp,T>){
    final id = __.uuid('xxxxx');
    final executions = [];//ersatz stream
    //Collector for errors related to the buffer.
    final context = Execute.context(executions).errate(e -> QueueFailure.fromDataFailure(e));

    if(buffer == null){
      buffer = new MemorySettableStoreOfTimeStamp();
    }
    function put(v:T){
      trace('$id put $v');
      //make sure the buffer is alright
      executions.push(buffer.set((LogicalClock.unit():TimeStampDef),v));
      return new Promise(
        (resolve,reject) -> {
          context.deliver(
            report -> for(e in report) reject(e)
          ).reply().handle(
            (_) -> {
              resolve(true);
            }
          );
        }
      );
    }
    final q = iqueue;

    q.onMessage = (t:T)-> {
      return put(t);
    }
      
    function is_ok_transformer(p:Promise<Bool>){
      final tr      = Pledge.trigger();
      p.then(
        (t:Bool) -> {
          tr.trigger(__.accept(t));
        },
        (a:Any) -> {
          tr.trigger(__.reject(f -> f.of(E_Io_Exception(new haxe.ValueException(a)))));
        } 
      );
      return tr;
    }
    var main    = null;
    final next  = __.hold(Held.Pause(
      () -> __.hold(Held.Guard(context.alert().flat_fold(
        er -> __.exit(er),
        () -> {
          return Future.sync(main);
        }
      )
    ))));
    main = __.tran(
     function rec(p:QueueInput<T>){
        trace('${id} ${p}');
        return switch(p){
          case QueueConfig(o) : 
            q.config(o);
            next;
          case QueueStart : 
            final p         = q.start();
            final trigger   = is_ok_transformer(p);
            __.hold(
              Held.Guard(
                trigger.toPledge().flat_fold(
                  b -> switch(b){
                    case true : next;
                    default   : __.quit(__.fault().of(E_Queue_Io(E_Io_CannotStart)));
                  },
                  e -> __.quit(e)
                )
              )
            );
          case QueueStop : 
            final p         = q.stop();
            final trigger   = is_ok_transformer(p);
            __.hold(
              Held.Guard(
                trigger.toPledge().flat_fold(
                  b -> switch(b){
                    case true : __.prod(Nada);
                    default   : __.quit(__.fault().of(E_Queue_Io(E_Io_CannotStop)));
                  },
                  e -> __.quit(e)
                )
              )
            );
          case QueueEnque(t) : 
            q.enqueue(t);
            next;
          case QueueReque(t,delay) : 
            q.requeue(t,delay);
            next;
          case QueueRequest(len) : 
            trace('$id request');
              var report = Report.unit();
              var value  = __.option();

            __.hold(Held.Guard(buffer.itr().errate(e -> QueueFailure.fromDataFailure(e)).point(
              keys -> {
                trace('$id keys ${keys}');
                if(len!=null){
                  keys = keys.ltaken(len);
                }
                
                return buffer.get_all(keys).errate(e -> QueueFailure.fromDataFailure(e)).command(
                  __.command(
                    (values:Cluster<T>) -> {
                      trace('$id values');
                      value = __.option(values);
                    }
                  )
                ).and(Execute.fromThunk(() -> buffer.del_all(keys).errate(e -> QueueFailure.fromDataFailure(e))));
              }
            ).deliver(
              (r) -> {
                for(err in r){
                  report = Report.pure(err);
                }
              } 
            ).reply().map(
              (_) -> return report.fold(
                e   -> __.exit(e),
                ()  -> __.emit(QueueReceive(value.defv([].imm())),next)
              )
            )));
        }
     }
    );
    // $type(main);
    // $type(context);
    
    return next;
  }
}
typedef QueueDef<T> = Coroutine<QueueInput<T>,QueueOutput<T>,Nada,QueueFailure>;

@:using(stx.asys.queue.Queue.QueueLift)
abstract Queue<T>(QueueDef<T>) from QueueDef<T> to QueueDef<T>{
  static public var _(default,never) = QueueLift;
  public inline function new(self:QueueDef<T>) this = self;
  @:noUsing static inline public function lift<T>(self:QueueDef<T>):Queue<T> return new Queue(self);

  public function prj():QueueDef<T> return this;
  private var self(get,never):Queue<T>;
  private function get_self():Queue<T> return lift(this);
}
class QueueLift{
  static public inline function lift<T>(self:QueueDef<T>):Queue<T>{
    return Queue.lift(self);
  }
}
