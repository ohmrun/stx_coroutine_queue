package stx.asys.queue;

enum QueueResponseSum<T>{
  QueueGot(cl:Cluster<T>);
}
@:using(stx.asys.queue.QueueResponse.QueueResponseLift)
abstract QueueResponse<T>(QueueResponseSum<T>) from QueueResponseSum<T> to QueueResponseSum<T>{
  static public var _(default,never) = QueueResponseLift;
  public inline function new(self:QueueResponseSum<T>) this = self;
  @:noUsing static inline public function lift<T>(self:QueueResponseSum<T>):QueueResponse<T> return new QueueResponse(self);

  public function prj():QueueResponseSum<T> return this;
  private var self(get,never):QueueResponse<T>;
  private function get_self():QueueResponse<T> return lift(this);
}
class QueueResponseLift{
  static public inline function lift<T>(self:QueueResponseSum<T>):QueueResponse<T>{
    return QueueResponse.lift(self);
  }
}