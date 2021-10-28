<template>

  <iframe  :id="id" :src="url" frameborder="0" width="100%" height="800px" scrolling="auto" style="background-color: #fff;"></iframe>

</template>

<script>

  import { deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'

  export default {
    name: "InstanceById",
    data () {
      return {
        url: "",
        id:""
      }
    },
    created () {
      this.goUrl()
    },
    updated () {
      this.goUrl()
    },
    watch: {
      $route(to, from) {
        this.goUrl();
      }
    },
    props:{
      dataSource:{
        type: Object,
        default: ()=>{},
        required: false
      }
    },
    methods: {
      goUrl () {
        let params = this.$route.params;
        this.url = window._CONFIG['monitoringInstanceURl'] +"?refresh=5m&orgId=1&var-TID=&var-TENANT="+params.projectName+"&var-HOSTNAME="+params.instanceName+"&var-UUID="+params.id;

      },
      openUrlNewWin(){
        window.open(this.url);
      }
    }
  }
</script>

<style>
</style>