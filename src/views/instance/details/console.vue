<template>

  <iframe  :id="id" :src="url" frameborder="0" width="100%" height="800px" scrolling="auto" style="background-color: #fff;"></iframe>

</template>

<script>

  import { deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'

  export default {
    name: "console",
    data () {
      return {
        url: "",
        id:""
      }
    },
    created () {
      this.goUrl(this.dataSource.id)
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
      goUrl (instanceID) {
        let url = this.$route.meta.url
        let id = this.$route.path
        this.id = id
        let that = this;
        if(instanceID){
          getAction("/openstack/osInstance/getConsoleUrl", {instanceID:instanceID }).then((res) => {
            if (res.success) {
              console.log(res.result)
              url =res.result;
              console.log("------url------"+url)
              if (url !== null && url !== undefined) {
                that.url = url;
                //window.open(this.url);
              }

            } else {
              //that.$message.warning(res.message);
            }

          });
          //url = "http://192.168.2.208:6080/vnc_lite.html?path=%3Ftoken%3D8f0b2851-07c3-44d5-94a9-1bfb024c568a"
        }


      }
    }
  }
</script>

<style>
</style>