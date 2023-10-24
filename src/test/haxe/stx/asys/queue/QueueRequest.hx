package stx.asys.queue;

enum QueueRequestSum<T>{ 
  QueueIdle;
  QueueConfig(o:Dynamic);
  QueueStart;
  QueueStop;
  QueueEnque(t:T);
  QueueReque(t:T,?delay:Int);
  QueueGet(?len:Null<Int>,?wait:Bool);
}
@:using(stx.asys.queue.QueueRequest.QueueRequestLift)
abstract QueueRequest<T>(QueueRequestSum<T>) from QueueRequestSum<T> to QueueRequestSum<T>{
  static public var _(default,never) = QueueRequestLift;
  public inline function new(self:QueueRequestSum<T>) this = self;
  @:noUsing static inline public function lift<T>(self:QueueRequestSum<T>):QueueRequest<T> return new QueueRequest(self);

  public function prj():QueueRequestSum<T> return this;
  private var self(get,never):QueueRequest<T>;
  private function get_self():QueueRequest<T> return lift(this);
}
class QueueRequestLift{
  static public inline function lift<T>(self:QueueRequestSum<T>):QueueRequest<T>{
    return QueueRequest.lift(self);
  }
}