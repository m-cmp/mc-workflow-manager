import request from "@/common/request";
import type { EventListener } from "@/views/type/type";


// Comment translated to English.
export const getEventListenerList = () => {
  return request.get('/eventlistener/list')
}

// Comment translated to English.
export function getEventListenerDetailInfo(eventlistenerIdx:number) {
  return request.get("/eventlistener/" + eventlistenerIdx);
}

// Comment translated to English.
export function duplicateCheck(eventListenerName:string) {
  return request.get(`/eventlistener/duplicate?eventlistenerName=${encodeURIComponent(eventListenerName)}`)
}

// Comment translated to English.
export function registEventListener(param: EventListener) {
  return request.post(`/eventlistener`, param)
}

// Comment translated to English.
export function updateEventListener(param: EventListener) {
  return request.patch(`/eventlistener/${param.eventListenerIdx}`, param)
}

// Comment translated to English.
export function deleteEventListener(eventlistenerIdx: number) {
  return request.delete(`/eventlistener/${eventlistenerIdx}`)
}











