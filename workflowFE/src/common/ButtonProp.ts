class ButtonProp {
  id: Number;
  isActive: boolean;
  caption: String;
  iconPath: String | null;
  callback: Function | null;
  param: Object | null;

  constructor(id: Number, isActive: boolean, caption: String, iconPath: string | null, callback: Function | null, param: Object | null) {
    this.id = id;
    this.isActive = isActive;
    this.caption = caption;
    this.iconPath = iconPath;
    this.callback = callback;
    this.param = param;
  }
}

export {
  ButtonProp
}
