package stx.coroutine.queue;

class QueueCtr extends Clazz{
  public function Make<T>(iqueue:IQueue<T>,?buffer:SettableStoreApi<TimeStamp,T>){
    final id          = __.uuid('xxxxx');
    final triggers    = Stream.trigger(); 
    final stream      = triggers.asStream();
    final context     = Execute.context(stream);

    if(buffer == null){
      buffer = new MemorySettableStoreOfTimeStamp();
    }
    function put(v:T){
      __.log().trace('$id put $v');
      //make sure the buffer is alright
      triggers.trigger(Val(buffer.set((LogicalClock.unit():TimeStampDef),v).errate(e -> QueueFailure.fromDataFailure(e))));
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
          q.onMessage = (t:T)-> { return put(t); }
      
    function is_ok_transformer(p:Promise<Bool>){
      return Pledge.lift(new Future(
        (cb) -> {
          p.then(
            (t:Bool) -> {
              __.log().trace('$id accept $t');
              cb(__.accept(t));
            },
            (a:Any) -> {
              __.log().trace('$id reject $a');
              cb(__.reject(f -> f.of(E_Io_Exception(new haxe.ValueException(a)))));
            } 
          );
          return ()->{};
        }
      ));
    }
    var main    = null;
    final call  = () -> {
      //execute context on turnaround
      __.log().trace('$id call');
      return __.hold(Held.Guard(context.alert().flat_fold(
        er -> __.exit(er),
        () -> {
          __.log().trace('$id main');
          return Future.irreversible(cb -> cb(main));
        }
      )));
    }
    final next  = __.hold(Held.Pause(call));
    main = __.tran(
     function rec(p:QueueRequest<T>){
        __.log().trace('${id} ${p}');
        return switch(p){
          case QueueConfig(o) : 
            q.config(o);
            next;
          case QueueStart : 
            final p         = q.start();
            final pledge   = is_ok_transformer(p);
            __.hold(
              Held.Guard(
                pledge.flat_fold(
                  b -> switch(b){
                    case true : __.hold(Held.Pause(call));
                    default   : __.quit(__.fault().of(E_Queue_Io(E_Io_CannotStart)));
                  },
                  e -> __.quit(e)
                )
              )
            );
          case QueueStop : 
            final p         = q.stop();
            final pledge   = is_ok_transformer(p);
            __.hold(
              Held.Guard(
                pledge.flat_fold(
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
          case QueueDeque(len,wait) : 
            __.log().trace('$id request');
            var report      = Report.unit();
            var done        = false;
            var value       = __.option();

            final keys        = buffer.itr().errate(e -> QueueFailure.fromDataFailure(e));
            
            final come_back_later = (len) -> {
              __.log().trace('$id do later');
              return __.tran(
                function(x:QueueRequest<T>){
                  __.log().trace('$id fork $x');
                  return switch(x){
                    case QueueEnque(_) : 
                      next.provide(x).provide(QueueDeque(len));
                    default :
                      next;
                  };
                }
              );
            }
            final get_values_now = (keys) -> { 
              __.log().trace('$id do now');
              return __.hold(
                Held.Arrow(
                  buffer.rem_all(keys).errate(e -> QueueFailure.fromDataFailure(e))
                        .map(arr -> __.emit(QueueGot(arr),next))
                )
              );
            }
            final together = keys.convert(
              keys -> {
                __.log().trace('$id $keys');
                if(len!=null){    keys = keys.ltaken(len); }
                if(len == null){  len = keys.length; }
                if(len == 0){     len = 1; }
                return if(wait && keys.length<len){
                  come_back_later(len);
                }else{
                  get_values_now(keys);
                };
              }
            );
            __.hold(Held.Arrow(together));
          case QueueIdle : 
            __.hold(Held.Pause(call));                
        }
     }
    );
    // $type(main);
    // $type(context);
    
    return next;
  }
}
typedef QueueDef<T> = Coroutine<QueueRequest<T>,QueueResponse<T>,Nada,QueueFailure>;

@:using(stx.coroutine.queue.Queue.QueueLift)
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
