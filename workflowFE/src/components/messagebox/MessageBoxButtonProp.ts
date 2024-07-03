class MessageBoxButtonProp {
  caption: String;
  callback: Function;
  param: Object | null;

  constructor(caption: string, callback: Function, param: Object | null) {
    this.caption = caption;
    this.callback = callback;
    this.param = param;
  }
}

export {
  MessageBoxButtonProp
}
