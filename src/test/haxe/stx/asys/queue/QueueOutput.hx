package stx.asys.queue;

enum QueueOutputSum<T>{
  QueueReceive(cl:Cluster<T>);
}
@:using(stx.asys.queue.QueueOutput.QueueOutputLift)
abstract QueueOutput<T>(QueueOutputSum<T>) from QueueOutputSum<T> to QueueOutputSum<T>{
  static public var _(default,never) = QueueOutputLift;
  public inline function new(self:QueueOutputSum<T>) this = self;
  @:noUsing static inline public function lift<T>(self:QueueOutputSum<T>):QueueOutput<T> return new QueueOutput(self);

  public function prj():QueueOutputSum<T> return this;
  private var self(get,never):QueueOutput<T>;
  private function get_self():QueueOutput<T> return lift(this);
}
class QueueOutputLift{
  static public inline function lift<T>(self:QueueOutputSum<T>):QueueOutput<T>{
    return QueueOutput.lift(self);
  }
}