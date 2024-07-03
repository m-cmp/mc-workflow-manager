/*
공통으로 사용하는 로딩 처리 기능
*/
import {UNUSED_PAGES} from '@/constant/common'
import { mapState as shareMapState } from '@/store/modules/share'
import {useRouter, useRoute} from "vue-router";

export default {
  data() {
    return {

    }
  },

  computed: {
    ...shareMapState(['projectInfo']),
  },

  created(){
    //프로젝트 타입별로 감춰야되는 페이지가 있어서 해당 코드로 처리
    // const routerName = this.$router.history.name;
    // const checkPages = UNUSED_PAGES["TYPE"+this.projectInfo.projectType] || [];
    // if(checkPages.find(x=>x==routerName)){
    //   this.$router.replace('/404');
    // }
  },

  methods: {

  }
}
