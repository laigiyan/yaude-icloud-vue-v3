<template>
  <a-card :bordered="false">

    <a-tabs>
      <a-tab-pane tab="基本信息" key="1" forceRender>
        <j-vxe-demo1/>
      </a-tab-pane>

      <a-tab-pane tab="控制臺" key="2" forceRender>
        <j-vxe-demo2/>
      </a-tab-pane>

      <a-tab-pane tab="操作日志" key="3" forceRender>
        <j-vxe-demo3/>
      </a-tab-pane>

    </a-tabs>
  </a-card>
</template>

<script>
  import JVxeDemo1 from '@views/jeecg/JVxeDemo/JVxeDemo1'
  import JVxeDemo2 from '@views/jeecg/JVxeDemo/JVxeDemo2'
  import JVxeDemo3 from '@views/jeecg/JVxeDemo/JVxeDemo3'

  export default {
    name: 'OsInstanceDetail',
    components: {JVxeDemo2, JVxeDemo1,JVxeDemo3},
    data() {
      return {}
    },
    methods: {},
  }
</script>

<style scoped>

</style>