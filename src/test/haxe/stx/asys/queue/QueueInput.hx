package stx.asys.queue;

enum QueueInputSum<T>{ 
  QueueConfig(o:Dynamic);
  QueueStart;
  QueueStop;
  QueueEnque(t:T);
  QueueReque(t:T,?delay:Int);
  QueueRequest(?len:Int);
}
@:using(stx.asys.queue.QueueInput.QueueInputLift)
abstract QueueInput<T>(QueueInputSum<T>) from QueueInputSum<T> to QueueInputSum<T>{
  static public var _(default,never) = QueueInputLift;
  public inline function new(self:QueueInputSum<T>) this = self;
  @:noUsing static inline public function lift<T>(self:QueueInputSum<T>):QueueInput<T> return new QueueInput(self);

  public function prj():QueueInputSum<T> return this;
  private var self(get,never):QueueInput<T>;
  private function get_self():QueueInput<T> return lift(this);
}
class QueueInputLift{
  static public inline function lift<T>(self:QueueInputSum<T>):QueueInput<T>{
    return QueueInput.lift(self);
  }
}