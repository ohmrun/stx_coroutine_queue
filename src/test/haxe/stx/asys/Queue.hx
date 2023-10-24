package stx.asys;

class  QueueModuleLift{
  static public function queue(self:stx.asys.Module){
    return new stx.asys.queue.Module();
  }
}
typedef QueueResponse<T>    = stx.asys.queue.QueueResponse<T>;
typedef QueueResponseSum<T> = stx.asys.queue.QueueResponse.QueueResponseSum<T>;

typedef QueueRequest<T>       = stx.asys.queue.QueueRequest<T>;
typedef QueueRequestSum<T>    = stx.asys.queue.QueueRequest.QueueRequestSum<T>;

typedef QueueCtr            = stx.asys.queue.Queue.QueueCtr;
typedef Queue<T>            = stx.asys.queue.Queue<T>;
typedef QueueDef<T>         = stx.asys.queue.Queue.QueueDef<T>;