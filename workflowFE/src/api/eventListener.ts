import request from "@/common/request";
import type { EventListener } from "@/views/type/type";
import { useUserStore } from "@/stores/user";

const selectedScope = () => {
  const user = useUserStore()
  return {
    workspaceId: String(user.workspaceInfo.id || ''),
    projectId: String(user.projectInfo.id || ''),
  }
}

// Comment translated to English.
export const getEventListenerList = () => {
  const user = useUserStore()
  return request.get('/eventlistener/list', {
    params: {
      ...selectedScope(),
      workspaceName: user.workspaceInfo.name,
      projectName: user.projectInfo.name,
    }
  })
}

// Comment translated to English.
export function getEventListenerDetailInfo(eventlistenerIdx:number) {
  return request.get("/eventlistener/" + eventlistenerIdx, { params: selectedScope() });
}

// Comment translated to English.
export function duplicateCheck(eventListenerName:string) {
  return request.get(`/eventlistener/duplicate?eventlistenerName=${encodeURIComponent(eventListenerName)}`)
}

// Comment translated to English.
export function registEventListener(param: EventListener) {
  return request.post(`/eventlistener`, { ...param, ...selectedScope() })
}

// Comment translated to English.
export function updateEventListener(param: EventListener) {
  return request.patch(`/eventlistener/${param.eventListenerIdx}`, { ...param, ...selectedScope() })
}

// Comment translated to English.
export function deleteEventListener(eventlistenerIdx: number) {
  return request.delete(`/eventlistener/${eventlistenerIdx}`, { params: selectedScope() })
}










