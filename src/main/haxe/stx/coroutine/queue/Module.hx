package stx.coroutine.queue;

class Module extends Clazz{
  @:isVar public var Queue(get,null):QueueCtr;
  private function get_Queue():QueueCtr{
    return __.option(this.Queue).def(() -> this.Queue = new QueueCtr());
  }
}