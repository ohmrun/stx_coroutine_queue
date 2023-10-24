package stx.coroutine;

class  QueueModuleLift{
  static public function queue(self:stx.coroutine.Module){
    return new stx.coroutine.queue.Module();
  }
}
typedef QueueResponse<T>    = stx.coroutine.queue.QueueResponse<T>;
typedef QueueResponseSum<T> = stx.coroutine.queue.QueueResponse.QueueResponseSum<T>;

typedef QueueRequest<T>       = stx.coroutine.queue.QueueRequest<T>;
typedef QueueRequestSum<T>    = stx.coroutine.queue.QueueRequest.QueueRequestSum<T>;

typedef QueueCtr            = stx.coroutine.queue.Queue.QueueCtr;
typedef Queue<T>            = stx.coroutine.queue.Queue<T>;
typedef QueueDef<T>         = stx.coroutine.queue.Queue.QueueDef<T>;