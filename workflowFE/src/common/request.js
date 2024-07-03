import Vue from "vue";
import axios, {AxiosRequestConfig, AxiosResponse, CancelToken} from "axios";
import store from "@/store";
import { rootActions } from "@/store";
import { useToast } from "vue-toastification";

const toast = useToast();

// create an axios instance
const service = axios.create({
    baseURL: process.env.VUE_APP_API_URL, // url = base url + request url
    timeout: 300000
});


// request interceptor
service.interceptors.request.use(
    config => {
        // console.log("##[", "api", "]##", "request", config.url, config);
        return config;
    },
    error => {
        // do something with request error
        console.log("error ---------- ", error); // for debug
        return Promise.reject(error);
    }
);

// response interceptor
service.interceptors.response.use(
    response => {
        // console.log("##[", "api", "]##", "response", response.config.url, response);
        const res = response.data;

        // 데이터 타입이 zip인 경우 유효성 처리 무시하기
        if (res.type == "application/zip") {
            return res;
        }

        // 데이터 타입이 json 파일인 경우 유효성 처리 무시하기
        if (res.type == "application/json") {
            return res;
        }

        // code==2200번인 경우만 활성화 처리
        if (res.code == 2200 || res.code === 20000 || res.code === 200 || res.code === 1107) {
            return res;
        } else {
            return Promise.reject(new Error(res.message || "Error"));
        }
    },
    error => {
        console.log("ApiService.Response -> fail", error);

        // axios에서 서버 요청을 취소한 경우에 실행.
        if (axios.isCancel(error)) {
            return Promise.reject(error);
        }
        toast.error(error.message)
        return Promise.reject(error);
    }
);

export { CancelToken };
export default service;
