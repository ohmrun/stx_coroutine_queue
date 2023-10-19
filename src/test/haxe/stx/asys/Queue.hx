package stx.asys;

class  QueueModuleLift{
  static public function queue(self:stx.asys.Module){
    return new stx.asys.queue.Module();
  }
}
typedef QueueOutput<T>    = stx.asys.queue.QueueOutput<T>;
typedef QueueOutputSum<T> = stx.asys.queue.QueueOutput.QueueOutputSum<T>;

typedef QueueInput<T>       = stx.asys.queue.QueueInput<T>;
typedef QueueInputSum<T>    = stx.asys.queue.QueueInput.QueueInputSum<T>;

typedef QueueCtr            = stx.asys.queue.Queue.QueueCtr;
typedef Queue<T>            = stx.asys.queue.Queue<T>;
typedef QueueDef<T>         = stx.asys.queue.Queue.QueueDef<T>;