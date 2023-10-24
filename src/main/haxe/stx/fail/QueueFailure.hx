package stx.fail;

using stx.Pico;
using stx.Nano;

enum QueueFailureSum{
  E_Queue_Io(e:IoFailure);
  E_Queue_ASys(e:ASysFailure);
  E_Queue_Data(e:DataFailure);
}

@:transitive abstract QueueFailure(QueueFailureSum) from QueueFailureSum to QueueFailureSum{
  public function new(self) this = self;
  @:noUsing static public function lift(self:QueueFailureSum):QueueFailure return new QueueFailure(self);

  public function prj():QueueFailureSum return this;
  private var self(get,never):QueueFailure;
  private function get_self():QueueFailure return lift(this);

  @:from static public function fromIoFailure(self:IoFailure){
    return lift(E_Queue_Io(self));
  }
  @:from static public function fromASysFailure(self:ASysFailure){
    return lift(E_Queue_ASys(self));
  }
  @:from static public function fromDataFailure(self:DataFailure){
    return lift(E_Queue_Data(self));
  }
}