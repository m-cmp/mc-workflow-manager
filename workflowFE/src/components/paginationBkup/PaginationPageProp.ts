export class PaginationPageProp {
  pageNo: number;
  isActive: boolean;

  constructor(pageNo: number, isActive: boolean) {
    this.pageNo = pageNo;
    this.isActive = isActive;
  }
}
