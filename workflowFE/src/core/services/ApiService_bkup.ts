import { App } from "vue";
import axios from "axios";
import request from "@/common/request.js"
// import JwtService from "@/core/services/JwtService";
import { AxiosResponse, AxiosRequestConfig } from "axios";
import store from "@/store";
import { Actions } from "@/store/enums/StoreEnums";
// import { getToken, setToken } from "@/core/services/AuthToken";
import VueAxios from "vue-axios";

/**
 * @description service to call HTTP request via Axios
 */
class ApiService {
  /**
   * @description property to share vue instance
   */
  public static vueInstance: App;

  /**
   * @description initialize vue axios
   */
  public static init(app: App<Element>) {
    ApiService.vueInstance = app;
    ApiService.vueInstance.use(VueAxios, axios);
    ApiService.vueInstance.axios.defaults.baseURL = process.env.VUE_APP_API_URL;

    ApiService.setInterceptor();
  }

  /**
   * @description set the default HTTP request headers
   */
  public static setHeader(): void {
    // ApiService.vueInstance.axios.defaults.headers.common[
    //   "Authorization"
    // ] = `Token ${JwtService.getToken()}`;
    ApiService.vueInstance.axios.defaults.headers.common["Accept"] =
      "application/json";
  }

  /**
   * @description send the GET HTTP request
   * @param resource: string
   * @param params: AxiosRequestConfig
   * @returns Promise<AxiosResponse>
   */
  public static query(
    resource: string,
    params: AxiosRequestConfig
  ): Promise<AxiosResponse> {
    console.log(
      "function : query | resource : ",
      resource,
      " | params : ",
      params
    );
    return ApiService.vueInstance.axios.get(resource, params);
  }

  public static queryPost(
    resource: string,
    params: AxiosRequestConfig
  ): Promise<AxiosResponse> {
    console.log(
      "function : queryPost | resource : ",
      resource,
      " | params : ",
      params,
      "url = " + `${resource}`
    );
    return ApiService.vueInstance.axios.post(`${resource}`, params.params);
  }

  /**
   * @description send the GET HTTP request
   * @param resource: string
   * @param slug: string
   * @returns Promise<AxiosResponse>
   */
  public static get(
    resource: string,
    slug = "" as string
  ): Promise<AxiosResponse> {
    return ApiService.vueInstance.axios.get(`${resource}/${slug}`);
  }

  /**
   * @description set the POST HTTP request
   * @param resource: string
   * @param params: AxiosRequestConfig
   * @returns Promise<AxiosResponse>
   */
  public static post(
    resource: string,
    params: AxiosRequestConfig
  ): Promise<AxiosResponse> {
    return ApiService.vueInstance.axios.post(`${resource}`, params);
  }

  /**
   * @description send the UPDATE HTTP request
   * @param resource: string
   * @param slug: string
   * @param params: AxiosRequestConfig
   * @returns Promise<AxiosResponse>
   */
  public static update(
    resource: string,
    slug: string,
    params: AxiosRequestConfig
  ): Promise<AxiosResponse> {
    return ApiService.vueInstance.axios.put(`${resource}/${slug}`, params);
  }

  /**
   * @description Send the PUT HTTP request
   * @param resource: string
   * @param params: AxiosRequestConfig
   * @returns Promise<AxiosResponse>
   */
  public static put(
    resource: string,
    params: AxiosRequestConfig
  ): Promise<AxiosResponse> {
    return ApiService.vueInstance.axios.put(`${resource}`, params);
  }

  /**
   * @description Send the DELETE HTTP request
   * @param resource: string
   * @returns Promise<AxiosResponse>
   */
  public static delete(resource: string): Promise<AxiosResponse> {
    return ApiService.vueInstance.axios.delete(resource);
  }

  /* =================================================================================================================== */
  // INTERCEPTOR
  /* =================================================================================================================== */

  static setInterceptor() {
    ApiService.setInterceptorRequest();
    // ApiService.setInterceptorResponse();
  }

  /* REQUEST */
  static setInterceptorRequest() {
    ApiService.vueInstance.axios.interceptors.request.use(
      (config) => {

        console.log("## api:", "request", config.url, config);

        if(getToken()) {

          // 토컨( )userId를 헤더에 넘기기)
          if(store.getters.userId) config.headers.user_id = store.getters.userId;

          config.headers.token = getToken();
        }

        return config;
      },
      (error) => {
        // do something with request error
        console.log("error ---------- ", error); // for debug
        return Promise.reject(error);
      }
    );
  }

  /* RESPONSE */
  // static setInterceptorResponse() {
  //   ApiService.vueInstance.axios.interceptors.response.use(
  //     (response) => {
  //       console.log("## api:", "response", response.config.url, response);
  //
  //       const res = response.data;
  //
  //       // 데이터 타입이 zip인 경우 유효성 처리 무시하기
  //       // if (res.type == "application/zip") {
  //       //   return response;
  //       // }
  //
  //       // 데이터 타입이 json 파일인 경우 유효성 처리 무시하기
  //       // if (res.type == "application/json") {
  //       //   return response;
  //       // }
  //
  //       // 2407 세션이 끊긴 경우
  //       if (res.code == 2407) {
  //         console.log("response code = 2407 (Login Required)");
  //
  //         store.dispatch(Actions.LOGOUT).then();
  //         console.log("logout");
  //         window.location.href = "/#/sign-in";
  //         return;
  //       }
  //
  //       return response;
  //     },
  //     (error) => {
  //       console.log("ApiService.Response -> fail", error);
  //
  //       // axios에서 서버 요청을 취소한 경우에 실행.
  //       if (axios.isCancel(error)) {
  //         return Promise.reject(error);
  //       }
  //
  //       return Promise.reject(error);
  //     }
  //   );
  // }
}

export default ApiService;
